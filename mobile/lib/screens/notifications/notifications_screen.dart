import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'Medication Reminder',
        'body': 'Time to take your controller inhaler.',
        'time': '5 min ago',
      },
      {
        'title': 'High Pollen Alert',
        'body': 'Pollen count is high in your area today.',
        'time': '1 hr ago',
      },
      {
        'title': 'Health Report Ready',
        'body': 'Your weekly health report is now available.',
        'time': 'Yesterday',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.teal,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('No notifications yet.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.teal),
                  title: Text(notification['title'] ?? ''),
                  subtitle: Text(notification['body'] ?? ''),
                  trailing: Text(
                    notification['time'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(notification['title'] ?? ''),
                        content: Text(notification['body'] ?? ''),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
