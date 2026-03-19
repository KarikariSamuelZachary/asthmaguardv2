import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';
import 'privacy_screen.dart';
import 'package:mobile/screens/notifications/notifications_screen.dart';
import '../device_connection/device_connection_screen.dart';
import 'appearance_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const SizedBox(height: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4285F4),
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text('Account'),
                onTap: () {
                  // TODO: Navigate to Account screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined,
                    color: Colors.blue),
                title: const Text('Notifications'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('About'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
                title: const Text('Privacy Policy'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.blue),
                title: const Text('Help & Support'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.blue),
                title: const Text('Appearance'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppearanceScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.blue),
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Logout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false)
                    .signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Asthmaguard v1.0.0',
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
