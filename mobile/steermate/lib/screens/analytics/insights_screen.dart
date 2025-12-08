import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InsightCard(
            icon: Icons.trending_up_rounded,
            title: 'Improving Trend',
            description: 'Your safety score has improved by 12% this week!',
            color: AppTheme.successColor,
            isPositive: true,
          ),
          _InsightCard(
            icon: Icons.warning_amber_rounded,
            title: 'Braking Pattern',
            description: 'You tend to brake hard at intersections. Try anticipating stops earlier.',
            color: AppTheme.warningColor,
            tips: ['Maintain safe following distance', 'Watch for yellow lights', 'Brake gradually'],
          ),
          _InsightCard(
            icon: Icons.speed_rounded,
            title: 'Speed Management',
            description: 'You exceeded speed limits 3 times this week. Most were on highways.',
            color: AppTheme.cautionColor,
            tips: ['Use cruise control on highways', 'Check speedometer regularly', 'Know the speed limits'],
          ),
          _InsightCard(
            icon: Icons.turn_right_rounded,
            title: 'Cornering',
            description: 'Great job! Your cornering speed has been safe in all trips.',
            color: AppTheme.successColor,
            isPositive: true,
          ),
          _InsightCard(
            icon: Icons.nightlight_rounded,
            title: 'Best Time to Drive',
            description: 'Your safest driving hours are between 10 AM - 2 PM.',
            color: AppTheme.accentColor,
            isPositive: true,
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isPositive;
  final List<String>? tips;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isPositive = false,
    this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          if (isPositive) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle, color: AppTheme.successColor, size: 18),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            if (tips != null && tips!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...tips!.map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(tip)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
