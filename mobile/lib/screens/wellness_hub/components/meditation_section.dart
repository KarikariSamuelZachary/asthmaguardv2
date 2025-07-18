import 'package:flutter/material.dart';

class MeditationSection extends StatelessWidget {
  final bool isDark;
  const MeditationSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.deepPurple.shade900.withOpacity(0.1)
            : Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meditation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Take a moment to meditate and clear your mind.'),
          SizedBox(height: 24),
          Text(
              'Close your eyes, focus on your breath, and let go of distractions.'),
        ],
      ),
    );
  }
}
