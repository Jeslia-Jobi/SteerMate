import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../config/theme.dart';

class EndTripScreen extends StatefulWidget {
  const EndTripScreen({super.key});

  @override
  State<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends State<EndTripScreen> {
  bool _isUploading = true;
  bool _uploadSuccess = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _uploadTrip();
  }

  Future<void> _uploadTrip() async {
    final tripProvider = context.read<TripProvider>();
    
    try {
      final trip = await tripProvider.endTrip();
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadSuccess = trip != null;
          if (trip == null) {
            _uploadError = 'Failed to upload trip';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadSuccess = false;
          _uploadError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trip = tripProvider.currentTrip;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Status Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isUploading
                      ? Colors.blue.withOpacity(0.1)
                      : _uploadSuccess
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.dangerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: _isUploading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Icon(
                        _uploadSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                        size: 60,
                        color: _uploadSuccess ? AppTheme.successColor : AppTheme.dangerColor,
                      ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _isUploading
                    ? 'Uploading Trip...'
                    : _uploadSuccess
                        ? 'Trip Complete!'
                        : 'Upload Failed',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                _isUploading
                    ? 'Please wait while we save your trip data'
                    : _uploadSuccess
                        ? 'Your trip has been saved successfully'
                        : _uploadError ?? 'An error occurred',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Trip Summary Card
              if (trip != null || !_isUploading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Trip Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SummaryStat(
                              icon: Icons.timer_outlined,
                              value: trip?.formattedDuration ?? '--',
                              label: 'Duration',
                            ),
                            _SummaryStat(
                              icon: Icons.straighten_outlined,
                              value: trip != null
                                  ? '${trip.distanceKm.toStringAsFixed(1)} km'
                                  : '--',
                              label: 'Distance',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SummaryStat(
                              icon: Icons.shield_outlined,
                              value: trip != null ? '${trip.safetyScore}%' : '--',
                              label: 'Safety Score',
                              valueColor: trip != null
                                  ? trip.safetyScore >= 80
                                      ? AppTheme.successColor
                                      : trip.safetyScore >= 60
                                          ? AppTheme.warningColor
                                          : AppTheme.dangerColor
                                  : null,
                            ),
                            _SummaryStat(
                              icon: Icons.warning_amber_outlined,
                              value: '${trip?.unsafeEvents ?? 0}',
                              label: 'Events',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Action Buttons
              if (!_isUploading) ...[
                if (_uploadSuccess && trip != null)
                  ElevatedButton(
                    onPressed: () => context.go('/trips/${trip.id}'),
                    child: const Text('View Trip Details'),
                  )
                else
                  ElevatedButton(
                    onPressed: _uploadTrip,
                    child: const Text('Retry Upload'),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
