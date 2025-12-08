import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/theme.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Data'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.analytics_outlined),
                  title: const Text('Share Anonymous Data'),
                  subtitle: const Text('Help improve SteerMate'),
                  value: settings.shareAnonymousData,
                  onChanged: (value) => settings.setShareAnonymousData(value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.image_outlined),
                  title: const Text('Upload Sign Images'),
                  subtitle: const Text('Share detected sign images'),
                  value: settings.uploadVideoRoi,
                  onChanged: (value) => settings.setUploadVideoRoi(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Export My Data'),
              subtitle: const Text('Download all your trip data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing data export...')));
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppTheme.dangerColor.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.dangerColor),
              title: const Text('Delete Account', style: TextStyle(color: AppTheme.dangerColor)),
              subtitle: const Text('Permanently delete your data'),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.dangerColor),
              onTap: () => _showDeleteConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This will permanently delete your account and all data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deletion requested')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
