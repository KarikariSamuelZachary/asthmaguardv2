import 'package:flutter/material.dart';
import '../../../../models/sound.dart';

class SoundCard extends StatelessWidget {
  final Sound sound;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onToggleFavorite;

  const SoundCard({
    super.key,
    required this.sound,
    required this.isPlaying,
    required this.onPlay,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: sound.imageName.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(sound.imageName),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            height: 140,
            width: double.infinity,
          ),
          // Overlay gradient
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Content
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sound.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sound.location,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filled(
                      onPressed: onPlay,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    IconButton.filled(
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        (sound as dynamic).isFavorite == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: (sound as dynamic).isFavorite == true
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
