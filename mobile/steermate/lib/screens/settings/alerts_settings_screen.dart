import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/theme.dart';

class AlertsSettingsScreen extends StatelessWidget {
  const AlertsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driving Alerts'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: const Text('Audio Alerts'),
                  value: settings.audioAlertsEnabled,
                  onChanged: (value) => settings.setAudioAlerts(value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text('Haptic Feedback'),
                  value: settings.hapticAlertsEnabled,
                  onChanged: (value) => settings.setHapticAlerts(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Sensitivity Thresholds', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _SliderSetting(
            title: 'Overspeed Margin',
            subtitle: '${settings.overspeedMargin.toInt()} km/h over limit',
            value: settings.overspeedMargin,
            min: 0,
            max: 20,
            onChanged: (value) => settings.setOverspeedMargin(value),
            color: AppTheme.dangerColor,
          ),
          _SliderSetting(
            title: 'Hard Brake Threshold',
            subtitle: '${settings.hardBrakeThreshold.abs().toStringAsFixed(1)} m/s²',
            value: settings.hardBrakeThreshold.abs(),
            min: 2,
            max: 6,
            onChanged: (value) => settings.setHardBrakeThreshold(-value),
            color: AppTheme.warningColor,
          ),
          _SliderSetting(
            title: 'Unsafe Curve Threshold',
            subtitle: '${settings.unsafeCurveThreshold.toStringAsFixed(1)} m/s²',
            value: settings.unsafeCurveThreshold,
            min: 1.5,
            max: 5,
            onChanged: (value) => settings.setUnsafeCurveThreshold(value),
            color: AppTheme.cautionColor,
          ),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final Color color;

  const _SliderSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
