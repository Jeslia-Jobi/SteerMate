import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/trip_provider.dart';
import '../../config/theme.dart';

class SafetyScoreScreen extends StatelessWidget {
  const SafetyScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final avgScore = tripProvider.weeklyAverageScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.push('/analytics/insights'),
            child: const Text('Insights', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Score
            _buildOverallScoreCard(context, avgScore),
            
            const SizedBox(height: 20),
            
            // Weekly Trend
            _buildWeeklyTrendCard(context),
            
            const SizedBox(height: 20),
            
            // Stats Grid
            _buildStatsGrid(context, tripProvider),
            
            const SizedBox(height: 20),
            
            // Event Distribution
            _buildEventDistributionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(BuildContext context, double score) {
    final color = score >= 80
        ? AppTheme.successColor
        : score >= 60
            ? AppTheme.warningColor
            : AppTheme.dangerColor;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text('Your Safety Score', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${score.round()}',
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
                      ),
                      const Text('out of 100', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              score >= 80 ? '🎉 Excellent!' : score >= 60 ? '👍 Good job!' : '⚠️ Needs improvement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrendCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Trend', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: [
                    _makeBarGroup(0, 75),
                    _makeBarGroup(1, 82),
                    _makeBarGroup(2, 68),
                    _makeBarGroup(3, 90),
                    _makeBarGroup(4, 85),
                    _makeBarGroup(5, 78),
                    _makeBarGroup(6, 88),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    final color = y >= 80 ? AppTheme.successColor : y >= 60 ? AppTheme.warningColor : AppTheme.dangerColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, TripProvider tripProvider) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.route_rounded,
            value: '${tripProvider.weeklyTripsCount}',
            label: 'Trips This Week',
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.warning_amber_rounded,
            value: '${tripProvider.trips.fold<int>(0, (sum, t) => sum + (t.unsafeEvents ?? 0))}',
            label: 'Total Events',
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDistributionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Distribution', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(value: 40, color: AppTheme.dangerColor, title: 'Brake', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                    PieChartSectionData(value: 30, color: AppTheme.warningColor, title: 'Speed', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                    PieChartSectionData(value: 20, color: AppTheme.cautionColor, title: 'Curve', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                    PieChartSectionData(value: 10, color: AppTheme.accentColor, title: 'Accel', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
