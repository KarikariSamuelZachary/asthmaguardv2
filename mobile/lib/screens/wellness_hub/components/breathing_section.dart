import 'package:flutter/material.dart';

class BreathingSection extends StatelessWidget {
  final bool isDark;
  const BreathingSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.teal.shade900.withOpacity(0.1)
            : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Breathing Exercise',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
              'Try this simple breathing exercise to relax and improve your lung function.'),
          SizedBox(height: 24),
          Text(
              'Inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds, hold for 4 seconds.'),
        ],
      ),
    );
  }
}
