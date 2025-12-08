"""Trips router for uploading trips and generating reports."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from models.user import User
from models.trip import Trip, TripEvent, SignDetection
from schemas.trip import TripUpload, TripResponse, TripSummary, TripReport
from utils.dependencies import get_db, get_current_user

router = APIRouter(prefix="/trips", tags=["Trips"])


@router.post("/upload", response_model=TripResponse, status_code=status.HTTP_201_CREATED)
async def upload_trip(
    trip_data: TripUpload,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload a complete trip with events and sign detections."""
    # Calculate unsafe events count
    unsafe_events_count = len(trip_data.events)
    
    # Create trip
    new_trip = Trip(
        user_id=current_user.id,
        start_time=trip_data.start_time,
        end_time=trip_data.end_time,
        duration_seconds=trip_data.duration_seconds,
        distance_m=trip_data.distance_m,
        avg_speed_m_s=trip_data.avg_speed_m_s,
        max_speed_m_s=trip_data.max_speed_m_s,
        unsafe_events=unsafe_events_count,
    )
    
    db.add(new_trip)
    await db.flush()  # Get the trip ID
    
    # Add events
    for event_data in trip_data.events:
        event = TripEvent(
            trip_id=new_trip.id,
            event_type=event_data.event_type,
            timestamp=event_data.timestamp,
            lat=event_data.lat,
            lon=event_data.lon,
            speed_m_s=event_data.speed_m_s,
            accel_m_s2=event_data.accel_m_s2,
        )
        db.add(event)
    
    # Add sign detections
    for sign_data in trip_data.sign_detections:
        sign = SignDetection(
            trip_id=new_trip.id,
            ts=sign_data.ts,
            sign_class=sign_data.sign_class,
            confidence=sign_data.confidence,
            bbox=sign_data.bbox,
        )
        db.add(sign)
    
    await db.commit()
    
    # Reload trip with relationships
    result = await db.execute(
        select(Trip)
        .options(selectinload(Trip.events), selectinload(Trip.sign_detections))
        .where(Trip.id == new_trip.id)
    )
    trip = result.scalar_one()
    
    return trip


@router.get("", response_model=list[TripSummary])
async def list_trips(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """List all trips for the current user."""
    result = await db.execute(
        select(Trip)
        .where(Trip.user_id == current_user.id)
        .order_by(Trip.created_at.desc())
    )
    trips = result.scalars().all()
    return trips


@router.get("/{trip_id}", response_model=TripResponse)
async def get_trip(
    trip_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get a specific trip with all details."""
    result = await db.execute(
        select(Trip)
        .options(selectinload(Trip.events), selectinload(Trip.sign_detections))
        .where(Trip.id == trip_id, Trip.user_id == current_user.id)
    )
    trip = result.scalar_one_or_none()
    
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    
    return trip


@router.get("/{trip_id}/report", response_model=TripReport)
async def get_trip_report(
    trip_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Generate a report for a specific trip with analytics and recommendations."""
    result = await db.execute(
        select(Trip)
        .options(selectinload(Trip.events), selectinload(Trip.sign_detections))
        .where(Trip.id == trip_id, Trip.user_id == current_user.id)
    )
    trip = result.scalar_one_or_none()
    
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    
    # Generate summary statistics
    event_types = {}
    for event in trip.events:
        event_types[event.event_type] = event_types.get(event.event_type, 0) + 1
    
    summary = {
        "total_events": len(trip.events),
        "events_by_type": event_types,
        "signs_detected": len(trip.sign_detections),
        "duration_minutes": (trip.duration_seconds or 0) / 60,
        "distance_km": (trip.distance_m or 0) / 1000,
    }
    
    # Generate recommendations based on events
    recommendations = []
    
    if event_types.get("hard_brake", 0) > 2:
        recommendations.append("Try to anticipate traffic conditions to avoid hard braking. Maintain safe following distance.")
    
    if event_types.get("overspeed", 0) > 0:
        recommendations.append("Be mindful of speed limits. Consider using cruise control on highways.")
    
    if event_types.get("harsh_accel", 0) > 2:
        recommendations.append("Smooth acceleration improves fuel efficiency and passenger comfort.")
    
    if event_types.get("unsafe_curve", 0) > 0:
        recommendations.append("Reduce speed before entering curves for better control and safety.")
    
    if not recommendations:
        recommendations.append("Great driving! Keep up the good habits.")
    
    return TripReport(
        trip=trip,
        summary=summary,
        recommendations=recommendations
    )
