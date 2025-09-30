import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? description;

  const SectionTitle({super.key, required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(description!, style: const TextStyle(color: Colors.grey)),
        ],
      ],
    );
  }
}


