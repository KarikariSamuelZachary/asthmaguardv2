import 'dart:math';

import 'package:flutter/material.dart';

class LiveSensorScreen extends StatefulWidget {
  final double temperature;
  final double pressure;
  final double humidity;
  final int? pm1;
  final int pm25;
  final int pm10;

  const LiveSensorScreen({
    Key? key,
    required this.temperature,
    required this.pressure,
    required this.humidity,
    this.pm1,
    required this.pm25,
    required this.pm10,
  }) : super(key: key);

  @override
  State<LiveSensorScreen> createState() => _LiveSensorScreenState();
}

class _LiveSensorScreenState extends State<LiveSensorScreen> {
  final Random _random = Random();

  late double temperature;
  late double pressure;
  late double humidity;
  late int pm1;
  late int pm25;
  late int pm10;

  // IMU sensor fields (randomized for demo)
  double accelX = 0, accelY = 0, accelZ = 0;
  double gyroX = 0, gyroY = 0, gyroZ = 0;
  double magX = 0, magY = 0, magZ = 0;

  @override
  void initState() {
    super.initState();
    _updateStateWithWidgetValues(false);
  }

  @override
  void didUpdateWidget(LiveSensorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.temperature != oldWidget.temperature ||
        widget.pressure != oldWidget.pressure ||
        widget.humidity != oldWidget.humidity ||
        widget.pm1 != oldWidget.pm1 ||
        widget.pm25 != oldWidget.pm25 ||
        widget.pm10 != oldWidget.pm10) {
      _updateStateWithWidgetValues(true);
    }
  }

  void _updateStateWithWidgetValues(bool shouldSetState) {
    void update() {
      temperature = widget.temperature;
      pressure = widget.pressure;
      humidity = widget.humidity;
      pm1 = widget.pm1 ?? 12; // Default value if not provided
      pm25 = widget.pm25;
      pm10 = widget.pm10;

      // Initialize IMU values
      accelX = (_random.nextDouble() * 2 - 1) * 2;
      accelY = (_random.nextDouble() * 2 - 1) * 2;
      accelZ = (_random.nextDouble() * 2 - 1) * 2;
      gyroX = (_random.nextDouble() * 2 - 1) * 5;
      gyroY = (_random.nextDouble() * 2 - 1) * 5;
      gyroZ = (_random.nextDouble() * 2 - 1) * 5;
      magX = (_random.nextDouble() * 2 - 1) * 50;
      magY = (_random.nextDouble() * 2 - 1) * 50;
      magZ = (_random.nextDouble() * 2 - 1) * 50;
    }

    if (shouldSetState) {
      setState(update);
    } else {
      update();
    }
  }

  int get _pm25 => pm25;

  String _getAirQualityShortString() {
    if (_pm25 <= 12) return 'Good';
    if (_pm25 <= 35) return 'Moderate';
    return 'Unhealthy';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Sensor Data',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.blue),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildSensorCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    value: '${temperature.toStringAsFixed(2)} °C',
                    color: Colors.orangeAccent,
                    isDark: isDark,
                    valueFontSize: 24,
                  ),
                  _buildSensorCard(
                    icon: Icons.speed,
                    title: 'Pressure',
                    value: '${pressure.toStringAsFixed(2)} hPa',
                    color: Colors.purple,
                    isDark: isDark,
                    valueFontSize: 24,
                  ),
                  _buildSensorCard(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '${humidity.toStringAsFixed(2)}%',
                    color: Colors.blue,
                    isDark: isDark,
                    valueFontSize: 24,
                  ),
                  _buildSensorCard(
                    icon: Icons.blur_on,
                    title: 'PM1.0',
                    value: '$pm1 μg/m³',
                    color: Colors.cyan,
                    isDark: isDark,
                    valueFontSize: 24,
                  ),
                  _buildSensorCard(
                    icon: Icons.air,
                    title: 'PM2.5',
                    value: '$pm25 μg/m³',
                    color: Colors.green,
                    isDark: isDark,
                    valueFontSize: 24,
                  ),
                  _buildSensorCard(
                    icon: Icons.air,
                    title: 'PM10',
                    value: '$pm10 μg/m³',
                    color: Colors.teal,
                    isDark: isDark,
                    valueFontSize: 24,
                  ),
                  _buildSensorCard(
                    icon: Icons.cloud,
                    title: 'Air Quality',
                    value: _getAirQualityShortString(),
                    color: Colors.lightBlue,
                    isDark: isDark,
                    valueFontSize: 24,
                  ),
                  _buildSensorCard(
                    icon: Icons.directions_run,
                    title: 'Accelerometer',
                    value:
                        'X: ${accelX.toStringAsFixed(2)}\nY: ${accelY.toStringAsFixed(2)}\nZ: ${accelZ.toStringAsFixed(2)}',
                    color: Colors.deepPurple,
                    isDark: isDark,
                    valueFontSize: 14,
                    verticalValues: true,
                  ),
                  _buildSensorCard(
                    icon: Icons.threesixty,
                    title: 'Gyroscope',
                    value:
                        'X: ${gyroX.toStringAsFixed(2)}\nY: ${gyroY.toStringAsFixed(2)}\nZ: ${gyroZ.toStringAsFixed(2)}',
                    color: Colors.deepOrange,
                    isDark: isDark,
                    valueFontSize: 14,
                    verticalValues: true,
                  ),
                  _buildSensorCard(
                    icon: Icons.explore,
                    title: 'Magnetometer',
                    value:
                        'X: ${magX.toStringAsFixed(2)}\nY: ${magY.toStringAsFixed(2)}\nZ: ${magZ.toStringAsFixed(2)}',
                    color: Colors.teal,
                    isDark: isDark,
                    valueFontSize: 14,
                    verticalValues: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    double valueFontSize = 12,
    bool verticalValues = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [color.withOpacity(0.3), color.withOpacity(0.1)]
              : [Colors.white, Colors.white.withOpacity(0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -15,
            right: -15,
            child: Icon(
              icon,
              size: 80,
              color: color.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalValues
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: value
                                .split('\n')
                                .map((line) => Text(
                                      line,
                                      style: TextStyle(
                                        fontSize: valueFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ))
                                .toList(),
                          )
                        : Text(
                            value,
                            style: TextStyle(
                              fontSize: valueFontSize,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
