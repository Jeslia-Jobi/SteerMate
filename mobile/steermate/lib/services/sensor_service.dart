import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

/// Sensor service for real GPS and accelerometer data
class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  // GPS streams and data
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;
  double _currentSpeedMs = 0;
  double _totalDistanceM = 0;

  // Accelerometer data
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _lastAccelMagnitude = 0;
  List<double> _accelHistory = [];
  static const int _accelHistorySize = 50; // ~1 second of data at 50Hz

  // Callbacks for UI updates
  Function(double speedMs, double totalDistanceM)? onLocationUpdate;
  Function(String eventType, double accelMagnitude)? onUnsafeEvent;

  // Thresholds (can be adjusted from settings)
  double hardBrakeThreshold = -4.0; // m/s²
  double harshAccelThreshold = 4.0; // m/s²
  double unsafeCurveThreshold = 3.0; // m/s² (lateral)

  // Getters
  double get currentSpeedMs => _currentSpeedMs;
  double get currentSpeedKmh => _currentSpeedMs * 3.6;
  double get totalDistanceM => _totalDistanceM;
  Position? get lastPosition => _lastPosition;

  /// Check if location services are available
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Start tracking location and sensors
  Future<bool> startTracking() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) return false;

    // Reset values
    _totalDistanceM = 0;
    _accelHistory.clear();

    // Start GPS tracking
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_handlePositionUpdate);

    // Start accelerometer tracking
    _accelSubscription = accelerometerEventStream().listen(_handleAccelUpdate);

    return true;
  }

  /// Stop tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _accelSubscription?.cancel();
    _accelSubscription = null;
  }

  /// Handle GPS position updates
  void _handlePositionUpdate(Position position) {
    // Calculate distance from last position
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistanceM += distance;
    }

    _lastPosition = position;
    _currentSpeedMs = position.speed >= 0 ? position.speed : 0;

    // Notify UI
    onLocationUpdate?.call(_currentSpeedMs, _totalDistanceM);
  }

  /// Handle accelerometer updates - detect unsafe events
  void _handleAccelUpdate(AccelerometerEvent event) {
    // Calculate total acceleration magnitude (excluding gravity)
    // For simplicity, we use Z-axis for braking/acceleration detection
    // and X/Y for lateral (curve) detection
    
    final longitudinalAccel = event.z; // Front/back (braking/acceleration)
    final lateralAccel = sqrt(event.x * event.x + event.y * event.y); // Lateral

    // Store history for smoothing
    _accelHistory.add(longitudinalAccel);
    if (_accelHistory.length > _accelHistorySize) {
      _accelHistory.removeAt(0);
    }

    // Calculate smoothed acceleration
    final smoothedAccel = _accelHistory.isNotEmpty
        ? _accelHistory.reduce((a, b) => a + b) / _accelHistory.length
        : 0.0;

    // Detect hard braking (negative acceleration)
    if (smoothedAccel < hardBrakeThreshold) {
      onUnsafeEvent?.call('hard_brake', smoothedAccel);
    }
    // Detect harsh acceleration
    else if (smoothedAccel > harshAccelThreshold) {
      onUnsafeEvent?.call('harsh_accel', smoothedAccel);
    }
    
    // Detect unsafe curves (lateral acceleration)
    if (lateralAccel > unsafeCurveThreshold && _currentSpeedMs > 5) {
      onUnsafeEvent?.call('unsafe_curve', lateralAccel);
    }

    _lastAccelMagnitude = smoothedAccel;
  }

  /// Calculate distance between two positions in meters
  double calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }
}
