import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _locationGranted = true;
  bool _motionGranted = true;
  bool _cameraGranted = false;
  bool _backgroundLocationGranted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Required permissions for SteerMate to work properly.', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          _PermissionTile(icon: Icons.location_on_rounded, title: 'Location', subtitle: 'Required for GPS speed and position', isGranted: _locationGranted, onRequest: () => setState(() => _locationGranted = true)),
          _PermissionTile(icon: Icons.sensors_rounded, title: 'Motion Sensors', subtitle: 'Required for acceleration detection', isGranted: _motionGranted, onRequest: () => setState(() => _motionGranted = true)),
          _PermissionTile(icon: Icons.camera_alt_rounded, title: 'Camera', subtitle: 'Optional for traffic sign detection', isGranted: _cameraGranted, isOptional: true, onRequest: () => setState(() => _cameraGranted = true)),
          _PermissionTile(icon: Icons.location_searching_rounded, title: 'Background Location', subtitle: 'For tracking while screen is off', isGranted: _backgroundLocationGranted, isOptional: true, onRequest: () => setState(() => _backgroundLocationGranted = true)),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final bool isOptional;
  final VoidCallback onRequest;

  const _PermissionTile({required this.icon, required this.title, required this.subtitle, required this.isGranted, this.isOptional = false, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: isGranted ? AppTheme.successColor : Colors.grey),
        title: Row(
          children: [
            Text(title),
            if (isOptional) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Text('Optional', style: TextStyle(fontSize: 10)))],
          ],
        ),
        subtitle: Text(subtitle),
        trailing: isGranted
            ? const Icon(Icons.check_circle_rounded, color: AppTheme.successColor)
            : ElevatedButton(onPressed: onRequest, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text('Grant')),
      ),
    );
  }
}
