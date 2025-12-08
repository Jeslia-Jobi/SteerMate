import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';

enum TripState { idle, starting, active, ending, uploading }

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();

  List<Trip> _trips = [];
  Trip? _currentTrip;
  TripReport? _currentReport;
  TripState _state = TripState.idle;
  bool _isLoading = false;
  String? _error;

  // Live trip data
  DateTime? _tripStartTime;
  double _currentSpeed = 0; // m/s
  double _currentSpeedLimit = 60; // km/h (default)
  double _totalDistance = 0; // meters
  List<TripEvent> _tripEvents = [];
  List<SignDetection> _signDetections = [];

  // Getters
  List<Trip> get trips => _trips;
  Trip? get currentTrip => _currentTrip;
  TripReport? get currentReport => _currentReport;
  TripState get state => _state;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get tripStartTime => _tripStartTime;
  double get currentSpeed => _currentSpeed;
  double get currentSpeedKmh => _currentSpeed * 3.6;
  double get currentSpeedLimit => _currentSpeedLimit;
  double get totalDistance => _totalDistance;
  double get totalDistanceKm => _totalDistance / 1000;
  List<TripEvent> get tripEvents => _tripEvents;
  bool get isOverspeed => currentSpeedKmh > _currentSpeedLimit;
  
  Duration get tripDuration {
    if (_tripStartTime == null) return Duration.zero;
    return DateTime.now().difference(_tripStartTime!);
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trips = await _tripService.getTrips();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTrip(int tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentTrip = await _tripService.getTrip(tripId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTripReport(int tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentReport = await _tripService.getTripReport(tripId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void startTrip() {
    _state = TripState.active;
    _tripStartTime = DateTime.now();
    _currentSpeed = 0;
    _totalDistance = 0;
    _tripEvents = [];
    _signDetections = [];
    notifyListeners();
  }

  void updateSpeed(double speedMs) {
    _currentSpeed = speedMs;
    notifyListeners();
  }

  void updateDistance(double distanceM) {
    _totalDistance = distanceM;
    notifyListeners();
  }

  void updateSpeedLimit(double limitKmh) {
    _currentSpeedLimit = limitKmh;
    notifyListeners();
  }

  void addEvent(TripEvent event) {
    _tripEvents.add(event);
    notifyListeners();
  }

  void addSignDetection(SignDetection sign) {
    _signDetections.add(sign);
    if (sign.speedLimit != null) {
      _currentSpeedLimit = sign.speedLimit!.toDouble();
    }
    notifyListeners();
  }

  Future<Trip?> endTrip() async {
    if (_tripStartTime == null) return null;

    _state = TripState.uploading;
    notifyListeners();

    final endTime = DateTime.now();
    final duration = endTime.difference(_tripStartTime!);

    final trip = Trip(
      startTime: _tripStartTime,
      endTime: endTime,
      durationSeconds: duration.inSeconds,
      distanceM: _totalDistance,
      avgSpeedMs: duration.inSeconds > 0 ? _totalDistance / duration.inSeconds : 0,
      maxSpeedMs: _currentSpeed, // Would track max in real implementation
      events: _tripEvents,
      signDetections: _signDetections,
    );

    try {
      final uploadedTrip = await _tripService.uploadTrip(trip);
      _currentTrip = uploadedTrip;
      _state = TripState.idle;
      
      // Reload trips list
      await loadTrips();
      
      notifyListeners();
      return uploadedTrip;
    } catch (e) {
      _error = e.toString();
      _state = TripState.idle;
      notifyListeners();
      return null;
    }
  }

  void cancelTrip() {
    _state = TripState.idle;
    _tripStartTime = null;
    _tripEvents = [];
    _signDetections = [];
    notifyListeners();
  }

  int get weeklyTripsCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _trips.where((t) => t.createdAt?.isAfter(weekAgo) ?? false).length;
  }

  double get weeklyAverageScore {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weeklyTrips = _trips.where((t) => t.createdAt?.isAfter(weekAgo) ?? false);
    if (weeklyTrips.isEmpty) return 100;
    return weeklyTrips.map((t) => t.safetyScore).reduce((a, b) => a + b) / weeklyTrips.length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
