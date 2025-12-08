import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: Column(children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.drive_eta_rounded, size: 40, color: Colors.white)),
            const SizedBox(height: 16),
            Text('SteerMate', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          ])),
          const SizedBox(height: 32),
          Text('Smartphone-based driver assistance system using real-time sensor fusion, AI traffic sign recognition, and behavioral analytics.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          Card(child: Column(children: [
            _InfoTile(icon: Icons.memory_rounded, title: 'ML Model', value: 'MobileNetV2-SSD'),
            const Divider(height: 1),
            _InfoTile(icon: Icons.sensors_rounded, title: 'EKF Fusion', value: '50 Hz IMU + 1 Hz GPS'),
            const Divider(height: 1),
            _InfoTile(icon: Icons.security_rounded, title: 'Security', value: 'JWT + bcrypt'),
          ])),
          const SizedBox(height: 24),
          Card(child: Column(children: [
            ListTile(title: const Text('Open Source Licenses'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
            const Divider(height: 1),
            ListTile(title: const Text('Terms of Service'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
            const Divider(height: 1),
            ListTile(title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ])),
          const SizedBox(height: 32),
          const Center(child: Text('© 2024 SteerMate', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon, color: AppTheme.primaryColor), title: Text(title), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)));
  }
}
