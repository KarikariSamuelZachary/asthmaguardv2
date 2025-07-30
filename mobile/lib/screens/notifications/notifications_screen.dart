import 'package:flutter/material.dart';
import 'package:mobile/services/alert_notification_service.dart';

final alertNotificationService = AlertNotificationService();

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = alertNotificationService.notificationLog;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF4285F4), // Blue
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: n['level'] == AlertLevel.danger
                        ? Colors.red
                        : n['level'] == AlertLevel.warning
                            ? Colors.orange
                            : Colors.blue,
                  ),
                  title: Text(n['title'] ?? ''),
                  subtitle: Text(n['body'] ?? ''),
                  trailing: Text(
                    n['timestamp'] != null
                        ? (n['timestamp'] as DateTime)
                            .toLocal()
                            .toString()
                            .substring(0, 16)
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
