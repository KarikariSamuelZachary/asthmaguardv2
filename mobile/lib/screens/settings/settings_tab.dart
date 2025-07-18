import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';
import 'privacy_screen.dart';
import 'package:mobile/screens/notifications/notifications_screen.dart';
import '../device_connection/device_connection_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: Colors.teal),
          title: const Text('Notifications'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.teal),
          title: const Text('About'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
          title: const Text('Privacy Policy'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline, color: Colors.teal),
          title: const Text('Help & Support'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.bluetooth, color: Colors.teal),
          title: const Text('Device Connection'),
          subtitle: const Text('Connect to Arduino Nano 33 BLE Sense'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DeviceConnectionScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
