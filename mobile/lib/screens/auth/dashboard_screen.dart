import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For exp function
import 'package:mobile/screens/notifications/notifications_screen.dart';
import 'package:mobile/screens/wellness_hub/wellness_hub.dart';
import 'package:mobile/screens/heatlth_metrics/bmr_calculator.dart';
import 'package:mobile/screens/emergency_contacts/emergency_contact.dart';
import 'package:mobile/screens/log_symptoms/log_symptoms_dialog.dart';
import 'package:mobile/screens/pollution_tracker/pollution_tracker_screen.dart';
import 'package:mobile/screens/health_report/health_report.dart';
import 'package:mobile/screens/settings/settings_tab.dart';
import 'package:mobile/screens/sensors/live_sensor_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:mobile/services/alert_notification_service.dart';

// Helper function to get color based on PM2.5 air quality value
Color getAirQualityColor(int? pm25) {
  if (pm25 == null) return Colors.green;

  if (pm25 <= 12) return Colors.green; // Good
  if (pm25 <= 35) return Colors.yellow; // Moderate
  if (pm25 <= 55) return Colors.orange; // Unhealthy for Sensitive Groups
  if (pm25 <= 150) return Colors.red; // Unhealthy
  if (pm25 <= 250) return Colors.purple; // Very Unhealthy
  return Colors.brown; // Hazardous
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  double _temperature = 23.0;
  double _pressure = 1012.0;
  int _pm25 = 10;
  int _pm10 = 15;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _tempChar;
  BluetoothCharacteristic? _pressureChar;
  BluetoothCharacteristic? _pm25Char;
  BluetoothCharacteristic? _pm10Char;
  String _fullName = 'User';
  bool _bleConnected = false;

  final Random _random = Random();
  Timer? _demoTimer;

  // Stream subscriptions for cleanup
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _tempSubscription;
  StreamSubscription<List<int>>? _pressureSubscription;
  StreamSubscription<List<int>>? _pm25Subscription;
  StreamSubscription<List<int>>? _pm10Subscription;

  final _alertService = AlertNotificationService();
  bool _alertedPM25 = false;
  bool _alertedPM10 = false;

  @override
  void initState() {
    super.initState();
    _alertService.init();
    _connectAndSubscribeBLE();
    _loadFullName();
    _startDemoTimer();
  }

  void _startDemoTimer() {
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_bleConnected) return; // Don't overwrite real BLE data
      if (!mounted) return;
      setState(() {
        _pm25 += 2;
        _pm10 += 3;
        _pm25 = _pm25.clamp(5, 200);
        _pm10 = _pm10.clamp(10, 300);
        _temperature += (_random.nextDouble() - 0.5) * 0.3;
        _pressure += (_random.nextDouble() - 0.5) * 0.8;
        _temperature = _temperature.clamp(18.0, 28.0);
        _pressure = _pressure.clamp(990.0, 1030.0);
      });
      // Notification logic
      if (_pm25 > 35 && !_alertedPM25) {
        _alertedPM25 = true;
        _alertService.showAlert(
          title: 'Air Quality Alert',
          body: 'PM2.5 levels are high ($_pm25 μg/m³)!',
          level: AlertLevel.warning,
          alertType: 'pm25',
        );
      }
      if (_pm10 > 50 && !_alertedPM10) {
        _alertedPM10 = true;
        _alertService.showAlert(
          title: 'Air Quality Alert',
          body: 'PM10 levels are high ($_pm10 μg/m³)!',
          level: AlertLevel.warning,
          alertType: 'pm10',
        );
      }
    });
  }

  Future<void> _loadFullName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fullName = prefs.getString('fullName') ?? 'User';
    });
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 1:
        return 'Pollution Tracker';
      case 2:
        return 'Live Sensor Data';
      case 3:
        return 'Health Report';
      case 4:
        return 'Settings';
      default:
        return '';
    }
  }

  Future<void> _connectAndSubscribeBLE() async {
    // Scan and connect to the Arduino Nano 33 BLE Sense
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name == "AsthmaGuard" && !_bleConnected) {
          await FlutterBluePlus.stopScan();
          _scanSubscription?.cancel();

          _device = r.device;
          await _device!.connect();
          _bleConnected = true;
          _demoTimer?.cancel(); // Stop demo data when real device connects

          List<BluetoothService> services = await _device!.discoverServices();
          final String serviceUuid = "00000000-5ec4-4083-81cd-a10b8d5cf6ec";
          final String tempUuid = "00000001-5ec4-4083-81cd-a10b8d5cf6ec";
          final String pressureUuid = "00000002-5ec4-4083-81cd-a10b8d5cf6ec";
          final String pm25Uuid = "00000003-5ec4-4083-81cd-a10b8d5cf6ec";
          final String pm10Uuid = "00000004-5ec4-4083-81cd-a10b8d5cf6ec";

          for (var service in services) {
            if (service.uuid.toString().toLowerCase() == serviceUuid) {
              for (var characteristic in service.characteristics) {
                final charUuid = characteristic.uuid.toString().toLowerCase();

                if (charUuid == tempUuid) {
                  _tempChar = characteristic;
                  await _tempChar!.setNotifyValue(true);
                  _tempSubscription = _tempChar!.value.listen((value) {
                    final tempValue = _parseStringValue(value);
                    if (mounted) setState(() => _temperature = tempValue);
                  });
                }
                if (charUuid == pressureUuid) {
                  _pressureChar = characteristic;
                  await _pressureChar!.setNotifyValue(true);
                  _pressureSubscription = _pressureChar!.value.listen((value) {
                    final pressureValue = _parseStringValue(value);
                    if (mounted) setState(() => _pressure = pressureValue);
                  });
                }
                if (charUuid == pm25Uuid) {
                  _pm25Char = characteristic;
                  await _pm25Char!.setNotifyValue(true);
                  _pm25Subscription = _pm25Char!.value.listen((value) {
                    String stringValue = String.fromCharCodes(value);
                    int? pm25Value = int.tryParse(stringValue);
                    if (mounted) setState(() => _pm25 = pm25Value ?? 0);
                  });
                }
                if (charUuid == pm10Uuid) {
                  _pm10Char = characteristic;
                  await _pm10Char!.setNotifyValue(true);
                  _pm10Subscription = _pm10Char!.value.listen((value) {
                    String stringValue = String.fromCharCodes(value);
                    int? pm10Value = int.tryParse(stringValue);
                    if (mounted) setState(() => _pm10 = pm10Value ?? 0);
                  });
                }
              }
            }
          }
          break;
        }
      }
    });
  }

  double _parseStringValue(List<int> bytes) {
    try {
      String stringValue = String.fromCharCodes(bytes);
      return double.tryParse(stringValue) ?? 0.0;
    } catch (e) {
      debugPrint("Error parsing BLE data: $e");
      return 0.0;
    }
  }

  // Calculate approximate humidity from temperature and pressure
  // This uses a simplified approach based on the Magnus formula
  double _calculateApproximateHumidity(double temperature, double pressure) {
    // Constants for Magnus formula
    const a = 17.27;
    const b = 237.7; // °C

    // Calculate saturation vapor pressure
    final satVapPres = 6.112 * exp((a * temperature) / (b + temperature));

    // Actual vapor pressure (approximation based on pressure)
    // This is a rough approximation and not scientifically accurate
    final actualVapPres = satVapPres * (1 - ((1013 - pressure) / 100) * 0.1);

    // Calculate relative humidity (guard against division by zero)
    double humidity = satVapPres > 0
        ? (actualVapPres / satVapPres) * 100
        : 50.0;

    // Ensure humidity is within 0-100% range
    humidity = humidity.clamp(0.0, 100.0);

    return humidity;
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _scanSubscription?.cancel();
    _tempSubscription?.cancel();
    _pressureSubscription?.cancel();
    _pm25Subscription?.cancel();
    _pm10Subscription?.cancel();
    if (_device != null && _device!.isConnected) {
      _device!.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the approximate humidity
    double humidity = _calculateApproximateHumidity(_temperature, _pressure);
    final List<Widget> _screens = [
      _HomeDashboard(
        temperature: _temperature,
        pressure: _pressure,
        humidity: humidity,
        pm25: _pm25,
        pm10: _pm10,
      ),
      const PollutionTrackerScreen(),
      LiveSensorScreen(
        temperature: _temperature,
        pressure: _pressure,
        humidity: humidity,
        pm25: _pm25,
        pm10: _pm10,
      ),
      const HealthReportScreen(),
      const SettingsTab(),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                'Hi, $_fullName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none,
                      size: 28, color: Colors.blue), // Changed color to blue
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _showProfileMenu(context);
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        "U",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Changed from teal to blue
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.air_outlined),
            label: 'Pollution',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensors',
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

  void _showProfileMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.blue),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

// Extracted Home dashboard content to a separate widget for cleaner tab switching
class _HomeDashboard extends StatelessWidget {
  final double temperature;
  final double pressure;
  final double humidity;
  final int pm25;
  final int pm10;

  const _HomeDashboard({
    Key? key,
    required this.temperature,
    required this.pressure,
    required this.humidity,
    required this.pm25,
    required this.pm10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF23272A)
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            Colors.blue.withOpacity(0.12), // Changed from teal
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_today,
                          color: Colors.blue, size: 28), // Changed from teal
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM d, yyyy').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.blue, // Changed from teal
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.wb_sunny_outlined,
                                  color: Colors.orangeAccent.shade700,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Sunny, AQI: 35 (Good)",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Health Tip: Remember to take your controller medication as prescribed to prevent asthma attacks.',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Environmental Metrics Section
            Text(
              'Environmental Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Changed from teal
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                SensorTile(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: '${temperature.toStringAsFixed(2)} °C',
                  color: Colors.orangeAccent,
                ),
                SensorTile(
                  icon: Icons.speed,
                  label: 'Pressure',
                  value: '${pressure.toStringAsFixed(2)} hPa',
                  color: Colors.purple,
                ),
                SensorTile(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${humidity.toStringAsFixed(2)}%',
                  color: Colors.blue,
                ),
                SensorTile(
                  icon: Icons.air,
                  label: 'Air Quality',
                  value: '$pm25 μg/m³',
                  color: getAirQualityColor(pm25),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Your Tools Section
            Text(
              'Your Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Changed from teal
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 1.1,
              children: [
                DashboardCard(
                  title: 'Health Tips',
                  icon: Icons.lightbulb_outline,
                  color: Colors.orangeAccent,
                  onTap: () => Navigator.pushNamed(context, '/health-tips'),
                ),
                DashboardCard(
                  title: 'Wellness Hub',
                  icon: Icons.self_improvement,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WellnessHub()),
                  ),
                ),
                DashboardCard(
                  title: 'BMR Calculator',
                  icon: Icons.calculate,
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BMRCalculator()),
                  ),
                ),
                DashboardCard(
                  title: 'Exercise Routines',
                  icon: Icons.fitness_center,
                  color: Colors.green,
                  onTap: () =>
                      Navigator.pushNamed(context, '/exercise-routines'),
                ),
                DashboardCard(
                  title: 'Medication Tracker',
                  icon: Icons.medication,
                  color: Colors.purple,
                  onTap: () =>
                      Navigator.pushNamed(context, '/medication-tracker'),
                ),
                DashboardCard(
                  title: 'Log Symptoms',
                  icon: Icons.sick,
                  color: Colors.redAccent,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => const LogSymptomsDialog(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.imagePath,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String? imagePath;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.13), color.withOpacity(0.07)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: color.withOpacity(0.18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (imagePath != null)
                    Image.asset(
                      imagePath!,
                      height: 48,
                      width: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(icon, size: 40, color: color);
                      },
                    )
                  else
                    Icon(icon, size: 40, color: color),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class SensorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const SensorTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.18) : color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
