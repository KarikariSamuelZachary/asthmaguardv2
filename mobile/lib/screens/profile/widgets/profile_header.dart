import 'package:flutter/material.dart';
import '../../../models/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileData profile;
  final bool isEditing;
  final bool isUpdating;
  final VoidCallback? onPhotoTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isEditing,
    required this.isUpdating,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double avatarRadius = 48;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              backgroundImage:
                  (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                      ? NetworkImage(profile.photoUrl!)
                      : null,
              child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                  ? const Icon(Icons.person, size: avatarRadius, color: Colors.grey)
                  : null,
            ),
            if (isEditing)
              Positioned(
                bottom: 0,
                right: MediaQuery.of(context).size.width / 2 - avatarRadius - 8,
                child: GestureDetector(
                  onTap: isUpdating ? null : onPhotoTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blueGrey : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.camera_alt,
                      color: isDark ? Colors.white : Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
              ),
            if (isUpdating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}
