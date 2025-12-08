import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../providers/trip_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/sensor_service.dart';
import '../../config/theme.dart';
import '../../models/trip.dart';

class LiveTripScreen extends StatefulWidget {
  const LiveTripScreen({super.key});

  @override
  State<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends State<LiveTripScreen> {
  Timer? _timer;
  String? _activeAlert;
  DateTime? _lastAlertTime;
  final SensorService _sensorService = SensorService();

  @override
  void initState() {
    super.initState();
    _startTrip();
  }

  Future<void> _startTrip() async {
    // Keep screen on during trip
    WakelockPlus.enable();
    
    // Start timer for UI updates
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    // Set up sensor callbacks
    final tripProvider = context.read<TripProvider>();
    final settings = context.read<SettingsProvider>();

    // Update thresholds from settings
    _sensorService.hardBrakeThreshold = settings.hardBrakeThreshold;
    _sensorService.harshAccelThreshold = settings.harshAccelThreshold;
    _sensorService.unsafeCurveThreshold = settings.unsafeCurveThreshold;

    // GPS updates
    _sensorService.onLocationUpdate = (speedMs, totalDistanceM) {
      tripProvider.updateSpeed(speedMs);
      tripProvider.updateDistance(totalDistanceM);
      
      // Check for overspeed
      final speedKmh = speedMs * 3.6;
      final speedLimit = tripProvider.currentSpeedLimit;
      if (speedKmh > speedLimit + settings.overspeedMargin) {
        _showAlert('overspeed', speedKmh);
      }
    };

    // Unsafe event detection
    _sensorService.onUnsafeEvent = (eventType, magnitude) {
      _showAlert(eventType, magnitude);
    };

    // Start real sensor tracking
    final started = await _sensorService.startTracking();
    if (!started && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access location. Please enable GPS.'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  void _showAlert(String alertType, double value) {
    // Debounce alerts (at least 3 seconds between same type)
    if (_lastAlertTime != null &&
        DateTime.now().difference(_lastAlertTime!) < const Duration(seconds: 3)) {
      return;
    }

    _lastAlertTime = DateTime.now();
    setState(() => _activeAlert = alertType);

    // Add event to trip
    final tripProvider = context.read<TripProvider>();
    final position = _sensorService.lastPosition;
    
    tripProvider.addEvent(TripEvent(
      eventType: alertType,
      timestamp: DateTime.now(),
      lat: position?.latitude,
      lon: position?.longitude,
      speedMs: tripProvider.currentSpeed,
      accelMs2: value,
    ));

    // Haptic feedback if enabled
    final settings = context.read<SettingsProvider>();
    if (settings.hapticAlertsEnabled) {
      // TODO: Add vibration
    }

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _activeAlert == alertType) {
        setState(() => _activeAlert = null);
      }
    });
  }

  Future<void> _endTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Trip?'),
        content: const Text('Are you sure you want to end this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _cleanup();
      context.go('/end-trip');
    }
  }

  void _cleanup() {
    _timer?.cancel();
    _sensorService.stopTracking();
    WakelockPlus.disable();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(tripProvider.tripDuration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Distance
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.straighten, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              settings.formatDistance(tripProvider.totalDistance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Speedometer
                _buildSpeedometer(tripProvider, settings),

                const SizedBox(height: 24),

                // Speed Limit Indicator
                _buildSpeedLimitIndicator(tripProvider),

                const Spacer(),

                // Events Count
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _EventBadge(
                        icon: Icons.warning_amber_rounded,
                        count: tripProvider.tripEvents.length,
                        label: 'Events',
                        color: tripProvider.tripEvents.isEmpty
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                    ],
                  ),
                ),

                // End Trip Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _endTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerColor,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop_rounded, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'End Trip',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Alert Overlay
            if (_activeAlert != null) _buildAlertOverlay(_activeAlert!),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedometer(TripProvider tripProvider, SettingsProvider settings) {
    final speedKmh = tripProvider.currentSpeedKmh;
    final isOverSpeed = tripProvider.isOverspeed;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            (isOverSpeed ? AppTheme.dangerColor : AppTheme.successColor).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: isOverSpeed ? AppTheme.dangerColor : AppTheme.successColor,
          width: 4,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            speedKmh.toStringAsFixed(0),
            style: TextStyle(
              color: isOverSpeed ? AppTheme.dangerColor : Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            settings.useMetricUnits ? 'km/h' : 'mph',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedLimitIndicator(TripProvider tripProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.dangerColor, width: 3),
            ),
            child: Center(
              child: Text(
                '${tripProvider.currentSpeedLimit.toInt()}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Speed Limit',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertOverlay(String alertType) {
    Color alertColor;
    IconData alertIcon;
    String alertText;

    switch (alertType) {
      case 'hard_brake':
        alertColor = AppTheme.dangerColor;
        alertIcon = Icons.warning_rounded;
        alertText = 'HARD BRAKING';
        break;
      case 'overspeed':
        alertColor = AppTheme.dangerColor;
        alertIcon = Icons.speed_rounded;
        alertText = 'SLOW DOWN';
        break;
      case 'harsh_accel':
        alertColor = AppTheme.warningColor;
        alertIcon = Icons.trending_up_rounded;
        alertText = 'HARSH ACCELERATION';
        break;
      case 'unsafe_curve':
        alertColor = AppTheme.cautionColor;
        alertIcon = Icons.turn_right_rounded;
        alertText = 'REDUCE SPEED';
        break;
      default:
        alertColor = AppTheme.warningColor;
        alertIcon = Icons.warning_rounded;
        alertText = 'ALERT';
    }

    return Positioned.fill(
      child: Container(
        color: alertColor.withOpacity(0.3),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: alertColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: alertColor.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(alertIcon, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  alertText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _EventBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _EventBadge({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
