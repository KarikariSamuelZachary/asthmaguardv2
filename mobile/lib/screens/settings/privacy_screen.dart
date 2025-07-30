import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Color(0xFF4285F4), // Blue
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with shield icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4285F4).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 40,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AsthmaGuard Privacy Policy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your health and privacy are our top priorities. We are committed to protecting your personal and health information as you use AsthmaGuard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildPrivacySection(
              context,
              icon: Icons.verified_user,
              title: 'Our Commitment',
              content:
                  'AsthmaGuard is designed to help you manage your asthma safely. We only collect data necessary for app functionality and your well-being.',
              isDark: isDark,
            ),
            _buildPrivacySection(
              context,
              icon: Icons.storage,
              title: 'What We Collect',
              content: 'To provide personalized asthma management, we collect:',
              isDark: isDark,
              listItems: [
                'Account Info: Name, email, and profile details',
                'Health Data: Asthma symptoms, medication logs, and health reports',
                'Device Data: Sensor readings (air quality, PM2.5, temperature, humidity)',
                'Usage Data: App interactions and preferences',
              ],
            ),
            _buildPrivacySection(
              context,
              icon: Icons.security,
              title: 'How We Protect Your Data',
              content:
                  'We use strong security practices to keep your data safe:',
              isDark: isDark,
              listItems: [
                'End-to-end encryption for sensitive health data',
                'Secure cloud storage and transmission',
                'Regular security reviews and updates',
                'Strict access controls',
              ],
            ),
            _buildPrivacySection(
              context,
              icon: Icons.share,
              title: 'Data Sharing',
              content: 'We never sell your data. We only share information:',
              isDark: isDark,
              listItems: [
                'With your explicit consent',
                'With service providers for app functionality (never for marketing)',
                'With authorities if required by law',
              ],
            ),
            _buildPrivacySection(
              context,
              icon: Icons.settings,
              title: 'Your Choices & Rights',
              content: 'You control your data in AsthmaGuard:',
              isDark: isDark,
              listItems: [
                'View and update your profile and health data',
                'Request data deletion at any time',
                'Control app permissions (Bluetooth, notifications, etc.)',
                'Opt out of non-essential communications',
              ],
            ),
            _buildPrivacySection(
              context,
              icon: Icons.update,
              title: 'Policy Updates',
              content:
                  'We may update this policy as AsthmaGuard evolves. We will notify you of significant changes in the app.',
              isDark: isDark,
            ),
            _buildPrivacySection(
              context,
              icon: Icons.email,
              title: 'Contact Us',
              content: 'Questions or concerns? Contact our privacy team:',
              isDark: isDark,
              contactEmails: [
                'skarikaripresecghana@gmail.com',
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Last updated: 27/07/2025',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
    List<String>? listItems,
    List<String>? contactEmails,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4285F4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (listItems != null) ...[
            const SizedBox(height: 8),
            ...listItems.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (contactEmails != null) ...[
            const SizedBox(height: 8),
            ...contactEmails.map((email) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4285F4),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
