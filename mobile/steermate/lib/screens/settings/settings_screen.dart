import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Preferences',
            children: [
              _SettingsTile(
                icon: Icons.tune_rounded,
                title: 'General',
                subtitle: 'Units, theme, ML settings',
                onTap: () => context.push('/settings/general'),
              ),
              _SettingsTile(
                icon: Icons.notifications_rounded,
                title: 'Driving Alerts',
                subtitle: 'Sensitivity and feedback',
                onTap: () => context.push('/settings/alerts'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Privacy & Security',
            children: [
              _SettingsTile(
                icon: Icons.verified_user_rounded,
                title: 'Permissions',
                subtitle: 'GPS, sensors, camera',
                onTap: () => context.push('/settings/permissions'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy & Data',
                subtitle: 'Data sharing, consent',
                onTap: () => context.push('/settings/privacy'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                title: 'Account Settings',
                subtitle: 'Profile, password',
                onTap: () => context.push('/settings/account'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Support',
            children: [
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                subtitle: 'FAQ and guides',
                onTap: () => context.push('/help'),
              ),
              _SettingsTile(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Support',
                subtitle: 'Get help from our team',
                onTap: () => context.push('/contact'),
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Version and licenses',
                onTap: () => context.push('/about'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Out?'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().logout();
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerColor),
            label: const Text('Log Out', style: TextStyle(color: AppTheme.dangerColor)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.dangerColor)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
