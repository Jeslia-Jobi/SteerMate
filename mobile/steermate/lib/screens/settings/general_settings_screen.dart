import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settings.isDarkMode,
            onChanged: (value) => settings.setDarkMode(value),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.speed_rounded),
            title: const Text('Metric Units'),
            subtitle: Text(settings.useMetricUnits ? 'Using km/h' : 'Using mph'),
            value: settings.useMetricUnits,
            onChanged: (value) => settings.setMetricUnits(value),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.smartphone_rounded),
            title: const Text('On-Device ML'),
            subtitle: const Text('Process AI on your phone'),
            value: settings.onDeviceML,
            onChanged: (value) => settings.setOnDeviceML(value),
          ),
        ],
      ),
    );
  }
}
