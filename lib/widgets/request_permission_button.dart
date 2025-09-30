import 'package:flutter/material.dart';

class RequestPermissionsButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const RequestPermissionsButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.lock_open),
      label: Text(isLoading ? 'Requesting...' : 'Request Permissions'),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
    );
  }
}
