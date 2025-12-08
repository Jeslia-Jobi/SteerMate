import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/trip_provider.dart';
import '../../config/theme.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadTripReport(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final report = tripProvider.currentReport;
          if (report == null) {
            return const Center(child: Text('Failed to load trip'));
          }

          final trip = report.trip;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Safety Score Card
                _buildSafetyScoreCard(context, trip.safetyScore),
                
                const SizedBox(height: 16),
                
                // Trip Stats
                _buildTripStatsCard(context, trip),
                
                const SizedBox(height: 16),
                
                // Events Summary
                if (trip.events.isNotEmpty)
                  _buildEventsCard(context, trip.events, report.summary),
                
                const SizedBox(height: 16),
                
                // Speed Chart (placeholder)
                _buildSpeedChartCard(context),
                
                const SizedBox(height: 16),
                
                // Recommendations
                if (report.recommendations.isNotEmpty)
                  _buildRecommendationsCard(context, report.recommendations),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSafetyScoreCard(BuildContext context, int score) {
    final color = score >= 80
        ? AppTheme.successColor
        : score >= 60
            ? AppTheme.warningColor
            : AppTheme.dangerColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety Score',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    score >= 80
                        ? 'Excellent driving!'
                        : score >= 60
                            ? 'Good, but room for improvement'
                            : 'Needs attention',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStatsCard(BuildContext context, trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(icon: Icons.timer_outlined, value: trip.formattedDuration, label: 'Duration'),
                _StatItem(icon: Icons.straighten_outlined, value: '${trip.distanceKm.toStringAsFixed(1)} km', label: 'Distance'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(icon: Icons.speed_outlined, value: '${trip.avgSpeedKmh.toStringAsFixed(0)} km/h', label: 'Avg Speed'),
                _StatItem(icon: Icons.speed, value: '${trip.maxSpeedKmh.toStringAsFixed(0)} km/h', label: 'Max Speed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCard(BuildContext context, List events, Map<String, dynamic> summary) {
    final eventsByType = summary['events_by_type'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Events', style: Theme.of(context).textTheme.titleLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${events.length} total',
                    style: const TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...eventsByType.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(_getEventIcon(entry.key), size: 20, color: _getEventColor(entry.key)),
                      const SizedBox(width: 8),
                      Text(_formatEventType(entry.key)),
                    ],
                  ),
                  Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedChartCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Speed Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 30),
                        FlSpot(2, 45),
                        FlSpot(3, 60),
                        FlSpot(4, 55),
                        FlSpot(5, 40),
                        FlSpot(6, 50),
                        FlSpot(7, 30),
                        FlSpot(8, 0),
                      ],
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, List<String> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Text('Recommendations', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20, color: AppTheme.successColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text(rec)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'hard_brake': return Icons.warning_rounded;
      case 'overspeed': return Icons.speed;
      case 'harsh_accel': return Icons.trending_up;
      case 'unsafe_curve': return Icons.turn_right;
      default: return Icons.error_outline;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'hard_brake': return AppTheme.dangerColor;
      case 'overspeed': return AppTheme.dangerColor;
      case 'harsh_accel': return AppTheme.warningColor;
      case 'unsafe_curve': return AppTheme.cautionColor;
      default: return Colors.grey;
    }
  }

  String _formatEventType(String type) {
    return type.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
