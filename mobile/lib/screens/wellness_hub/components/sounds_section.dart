import 'package:flutter/material.dart';

class SoundsSection extends StatelessWidget {
  final bool isDark;
  final String? currentSound;
  final ValueChanged<String?> setCurrentSound;
  final bool isPlaying;
  final ValueChanged<bool> setIsPlaying;
  final double volume;
  final ValueChanged<double> setVolume;
  final dynamic audioRef;
  const SoundsSection({
    super.key,
    required this.isDark,
    required this.currentSound,
    required this.setCurrentSound,
    required this.isPlaying,
    required this.setIsPlaying,
    required this.volume,
    required this.setVolume,
    required this.audioRef,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blueGrey.shade900.withOpacity(0.1)
            : Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Relaxing Sounds',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Sound player UI coming soon...'),
        ],
      ),
    );
  }
}
