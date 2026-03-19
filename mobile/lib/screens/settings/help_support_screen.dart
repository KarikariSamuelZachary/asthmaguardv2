import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color primaryBlue = Color(0xFF4285F4);
  static const Color lightBlue = Color(0xFFE3F0FF);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Optionally, show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          _buildSectionTitle('Frequently Asked Questions'),
          const SizedBox(height: 8),
          _FaqItem(
            question: 'What is AsthmaGuard?',
            answer:
                'AsthmaGuard is a comprehensive mobile application designed to help individuals manage their asthma more effectively. It tracks environmental triggers, logs symptoms, and provides personalized insights to help you stay in control of your health.',
            color: lightBlue,
            accent: primaryBlue,
          ),
          _FaqItem(
            question: 'How does the sensor device work?',
            answer:
                'The sensor monitors air quality (PM2.5), temperature, and humidity. It sends this data to the app via Bluetooth for real-time tracking of asthma triggers.',
            color: lightBlue,
            accent: primaryBlue,
          ),
          _FaqItem(
            question: 'Is my data secure?',
            answer:
                'Yes, your data is encrypted and stored securely. We do not share your data with third parties without your explicit consent.',
            color: lightBlue,
            accent: primaryBlue,
          ),
          _FaqItem(
            question: 'How do I connect my sensor device?',
            answer:
                'Enable Bluetooth, go to the "Device" tab, tap "Connect Device", and follow the instructions to pair your AsthmaGuard sensor.',
            color: lightBlue,
            accent: primaryBlue,
          ),
          const Divider(height: 40),
          _buildSectionTitle('Contact & Community'),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'skarikaripresecghana@gmail.com',
            color: primaryBlue,
            onTap: () => _launchUrl(
                'mailto:skarikaripresecghana@gmail.com?subject=AsthmaGuard Support Request'),
          ),
          const SizedBox(height: 10),
          _buildContactCard(
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            subtitle: 'Let us know about any issues',
            color: Colors.redAccent,
            onTap: () => _launchUrl(
                'mailto:skarikaripresecghana@gmail.com?subject=Bug Report'),
          ),
          const SizedBox(height: 10),
          _buildContactCard(
            icon: Icons.public,
            title: 'Visit our Website',
            subtitle: 'www.asthmaguard.com',
            color: primaryBlue,
            onTap: () => _launchUrl('https://www.asthmaguard.com'),
          ),
          const SizedBox(height: 10),
          _buildContactCard(
            icon: Icons.forum_outlined,
            title: 'Community Forum',
            subtitle: 'Join the discussion',
            color: Colors.deepPurple,
            onTap: () => _launchUrl(
                'https://community.asthmaguard.com'), // Replace with real link
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(Icons.verified_user, color: primaryBlue, size: 32),
                const SizedBox(height: 8),
                Text(
                  'We are here to help you 24/7',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Last updated: July 2025',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final Color color;
  final Color accent;

  const _FaqItem(
      {required this.question,
      required this.answer,
      required this.color,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: accent.withOpacity(0.08),
          highlightColor: accent.withOpacity(0.04),
        ),
        child: ExpansionTile(
          iconColor: accent,
          collapsedIconColor: accent,
          title: Text(
            question,
            style: TextStyle(fontWeight: FontWeight.w600, color: accent),
          ),
          childrenPadding: const EdgeInsets.all(16.0),
          children: [
            Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
