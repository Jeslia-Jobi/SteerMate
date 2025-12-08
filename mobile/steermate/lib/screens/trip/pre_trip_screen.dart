import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../config/theme.dart';

class PreTripScreen extends StatefulWidget {
  const PreTripScreen({super.key});

  @override
  State<PreTripScreen> createState() => _PreTripScreenState();
}

class _PreTripScreenState extends State<PreTripScreen> {
  bool _gpsReady = false;
  bool _imuReady = false;
  bool _permissionsGranted = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _runChecks();
  }

  Future<void> _runChecks() async {
    setState(() => _isChecking = true);

    // Simulate checking GPS
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _gpsReady = true);

    // Simulate checking IMU
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _imuReady = true);

    // Simulate checking permissions
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _permissionsGranted = true;
        _isChecking = false;
      });
    }
  }

  bool get _allChecksPass => _gpsReady && _imuReady && _permissionsGranted;

  void _startTrip() {
    context.read<TripProvider>().startTrip();
    context.go('/live-trip');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Trip Check'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Text(
                'System Check',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Verifying all sensors are ready',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Check Items
              _CheckItem(
                icon: Icons.gps_fixed_rounded,
                label: 'GPS Location',
                description: 'Required for speed and position tracking',
                isReady: _gpsReady,
                isChecking: _isChecking && !_gpsReady,
              ),
              
              const SizedBox(height: 16),
              
              _CheckItem(
                icon: Icons.sensors_rounded,
                label: 'Motion Sensors',
                description: 'Accelerometer and gyroscope for detection',
                isReady: _imuReady,
                isChecking: _isChecking && _gpsReady && !_imuReady,
              ),
              
              const SizedBox(height: 16),
              
              _CheckItem(
                icon: Icons.verified_user_rounded,
                label: 'Permissions',
                description: 'All required permissions granted',
                isReady: _permissionsGranted,
                isChecking: _isChecking && _imuReady && !_permissionsGranted,
              ),

              const Spacer(),

              // Status Message
              if (_allChecksPass)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.successColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All systems ready! You can start your trip.',
                          style: TextStyle(color: AppTheme.successColor),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Start Button
              ElevatedButton(
                onPressed: _allChecksPass ? _startTrip : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.successColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      _allChecksPass ? 'Start Trip' : 'Checking...',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Retry Button
              if (!_isChecking && !_allChecksPass)
                OutlinedButton(
                  onPressed: _runChecks,
                  child: const Text('Retry Checks'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isReady;
  final bool isChecking;

  const _CheckItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.isReady,
    required this.isChecking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady
              ? AppTheme.successColor.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isReady
                  ? AppTheme.successColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isReady ? AppTheme.successColor : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isChecking)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isReady)
            const Icon(Icons.check_circle_rounded, color: AppTheme.successColor)
          else
            const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        ],
      ),
    );
  }
}
