import 'package:mobile/services/alert_notification_service.dart';

final alertNotificationService = AlertNotificationService();

void checkSensorDataAndAlert({
  double? temperature,
  double? pressure,
  double? humidity,
  int? pm1,
  int? pm25,
  int? pm10,
}) {
  if (temperature != null && (temperature < 15 || temperature > 35)) {
    alertNotificationService.showAlert(
      title: 'Temperature Alert',
      body:
          'Temperature is [24m{temperature.toStringAsFixed(1)}[0m°C, which is outside the comfortable range.',
      alertType: 'temperature',
      level: AlertLevel.warning,
    );
  }
  if (humidity != null && (humidity < 30 || humidity > 70)) {
    alertNotificationService.showAlert(
      title: 'Humidity Alert',
      body:
          'Humidity is [24m{humidity.toStringAsFixed(1)}[0m%, which may affect breathing comfort.',
      alertType: 'humidity',
      level: AlertLevel.info,
    );
  }
  if (pressure != null && (pressure < 980 || pressure > 1030)) {
    alertNotificationService.showAlert(
      title: 'Pressure Alert',
      body:
          'Pressure is [24m{pressure.toStringAsFixed(1)}[0m hPa, which could affect sensitive individuals.',
      alertType: 'pressure',
      level: AlertLevel.info,
    );
  }
  if (pm1 != null && pm1 > 50) {
    alertNotificationService.showAlert(
      title: 'High PM1.0 Alert',
      body:
          'PM1.0 is $pm1 μg/m³. High levels of fine particles can be dangerous.',
      alertType: 'pm1.0',
      level: AlertLevel.danger,
    );
  }
  if (pm25 != null && pm25 > 35) {
    alertNotificationService.showAlert(
      title: 'High PM2.5 Alert',
      body:
          'PM2.5 is $pm25 μg/m³. High levels of fine particles can be dangerous.',
      alertType: 'pm2.5',
      level: AlertLevel.danger,
    );
  }
  if (pm10 != null && pm10 > 70) {
    alertNotificationService.showAlert(
      title: 'High PM10 Alert',
      body: 'PM10 is $pm10 μg/m³. Consider wearing a mask outdoors.',
      alertType: 'pm10',
      level: AlertLevel.warning,
    );
  }
}
