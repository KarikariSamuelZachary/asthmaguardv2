import 'package:flutter/material.dart';

class SectionNavigation extends StatelessWidget {
  final String activeSection;
  final ValueChanged<String> onSectionChange;
  const SectionNavigation(
      {super.key, required this.activeSection, required this.onSectionChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTab(context, 'breathing', 'Breathing'),
        _buildTab(context, 'meditation', 'Meditation'),
        _buildTab(context, 'sounds', 'Sounds'),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String section, String label) {
    final bool isActive = section == activeSection;
    return GestureDetector(
      onTap: () => onSectionChange(section),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
