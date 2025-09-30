import 'package:flutter/material.dart';
import 'package:step_track/providers/health_provider.dart';

class PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final PermissionStatus status;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusDetails = _statusDetails(status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Icon(statusDetails.icon, color: statusDetails.color),
                const SizedBox(height: 4),
                Text(
                  statusDetails.text,
                  style: TextStyle(color: statusDetails.color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusDetails _statusDetails(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return _StatusDetails(Icons.check_circle, Colors.green, 'Granted');
      case PermissionStatus.denied:
        return _StatusDetails(Icons.cancel, Colors.orange, 'Denied');
      case PermissionStatus.permanentlyDenied:
        return _StatusDetails(Icons.block, Colors.red, 'Blocked');
      case PermissionStatus.unknown:
      default:
        return _StatusDetails(Icons.help_outline, Colors.grey, 'Unknown');
    }
  }
}

class _StatusDetails {
  final IconData icon;
  final Color color;
  final String text;
  _StatusDetails(this.icon, this.color, this.text);
}
