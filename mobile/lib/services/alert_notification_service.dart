import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

enum AlertLevel { info, warning, danger }

class AlertNotificationService {
  static final AlertNotificationService _instance =
      AlertNotificationService._internal();
  factory AlertNotificationService() => _instance;
  AlertNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Map<String, DateTime> _lastAlertTimes = {};
  static const Duration _cooldown = Duration(minutes: 5);
  final List<Map<String, dynamic>> _notificationLog = [];

  List<Map<String, dynamic>> get notificationLog =>
      List.unmodifiable(_notificationLog);

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  Future<void> showAlert({
    required String title,
    required String body,
    required AlertLevel level,
    String alertType = 'general',
  }) async {
    final now = DateTime.now();
    if (_lastAlertTimes[alertType] != null &&
        now.difference(_lastAlertTimes[alertType]!) < _cooldown) {
      return;
    }
    _lastAlertTimes[alertType] = now;

    // Store in log
    _notificationLog.insert(0, {
      'title': title,
      'body': body,
      'level': level,
      'alertType': alertType,
      'timestamp': now,
    });

    final androidDetails = AndroidNotificationDetails(
      'emergency_alerts',
      'Emergency Alerts',
      channelDescription:
          'Notifications for air quality and environment alerts',
      importance: _getImportance(level),
      priority: _getPriority(level),
      color: _getColor(level),
      playSound: true,
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(0, title, body, details);
  }

  Importance _getImportance(AlertLevel level) {
    switch (level) {
      case AlertLevel.danger:
        return Importance.max;
      case AlertLevel.warning:
        return Importance.high;
      case AlertLevel.info:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(AlertLevel level) {
    switch (level) {
      case AlertLevel.danger:
        return Priority.max;
      case AlertLevel.warning:
        return Priority.high;
      case AlertLevel.info:
        return Priority.defaultPriority;
    }
  }

  Color _getColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.danger:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.info:
        return Colors.blue;
    }
  }
}
