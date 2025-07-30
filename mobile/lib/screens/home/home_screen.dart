import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/screens/home/tabs/dashboard_tab.dart';
import 'package:mobile/screens/pollution_tracker/pollution_tracker_screen.dart';
import 'package:mobile/screens/health_report/health_report.dart';
import 'package:mobile/screens/settings/settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const PollutionTrackerScreen(),
    const HealthReportScreen(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4285F4),
        unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.air_outlined),
            label: 'Pollution',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final Random _random = Random();

  double temperature = 0;
  double pressure = 0;
  double humidity = 0;
  int pm1 = 0;
  int pm25 = 0;
  int pm10 = 0;
  String airQuality = 'N/A';

  @override
  void initState() {
    super.initState();
    _generateRandomValues();
    // Update values every 3 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() => _generateRandomValues());
      return true;
    });
  }

  void _generateRandomValues() {
    temperature = 18 + _random.nextDouble() * 10; // 18°C to 28°C
    pressure = 990 + _random.nextDouble() * 20; // 990 hPa to 1010 hPa
    humidity = 40 + _random.nextDouble() * 30; // 40% to 70%
    pm1 = _random.nextInt(15) + 5; // 5 to 20 µg/m³
    pm25 = _random.nextInt(20) + 5; // 5 to 25 µg/m³
    pm10 = _random.nextInt(30) + 10; // 10 to 40 µg/m³
    airQuality = _getAirQuality(pm25);
  }

  String _getAirQuality(int pm25) {
    if (pm25 <= 12) return 'Good';
    if (pm25 <= 35) return 'Moderate';
    return 'Unhealthy';
  }

  @override
  Widget build(BuildContext context) {
    // Replace this with your actual dashboard UI
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Temperature: ${temperature.toStringAsFixed(1)} °C'),
        Text('Pressure: ${pressure.toStringAsFixed(1)} hPa'),
        Text('Humidity: ${humidity.toStringAsFixed(1)} %'),
        Text('PM1.0: $pm1 µg/m³'),
        Text('PM2.5: $pm25 µg/m³'),
        Text('PM10: $pm10 µg/m³'),
        Text('Air Quality: $airQuality'),
      ],
    );
  }
}
