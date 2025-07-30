import 'package:flutter/material.dart';

class SectionNavigation extends StatelessWidget {
  final String activeSection;
  final Function(String) onSectionChange;

  const SectionNavigation({
    super.key,
    required this.activeSection,
    required this.onSectionChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'breathing',
            label:
                Text('Breathing', overflow: TextOverflow.ellipsis, maxLines: 1),
            icon: Icon(Icons.air, color: Colors.blue),
          ),
          ButtonSegment(
            value: 'meditation',
            label: Text('Meditation',
                overflow: TextOverflow.ellipsis, maxLines: 1),
            icon: Icon(Icons.self_improvement, color: Colors.purple),
          ),
          ButtonSegment(
            value: 'sounds',
            label: Text('Sounds', overflow: TextOverflow.ellipsis, maxLines: 1),
            icon: Icon(Icons.music_note, color: Colors.green),
          ),
        ],
        selected: {activeSection},
        onSelectionChanged: (selection) => onSectionChange(selection.first),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF4285F4).withOpacity(0.15);
            }
            return isDark ? Colors.black12 : Colors.grey[100];
          }),
        ),
      ),
    );
  }
}
