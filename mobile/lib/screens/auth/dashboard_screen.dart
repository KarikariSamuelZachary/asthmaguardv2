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
  BluetoothCharacteristic? _pm25Char; // For PM2.5 characteristic
  BluetoothCharacteristic? _pm10Char; // For PM10 characteristic
  Stream<List<int>>? _tempStream;
  Stream<List<int>>? _pressureStream;
  Stream<List<int>>? _pm25Stream; // For PM2.5 stream
  Stream<List<int>>? _pm10Stream; // For PM10 stream;
  String _fullName = 'User';

  final Random _random = Random();
  Timer? _demoTimer;

  // Add this for notification service
  final _alertService = AlertNotificationService();
  bool _alertedPM25 = false;
  bool _alertedPM10 = false;
  bool _alertedPM1 = false;

  @override
  void initState() {
    super.initState();
    _alertService.init();
    _connectAndSubscribeBLE();
    _loadFullName();
    _demoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        // Simulate increasing PM values
        _pm25 += 2;
        _pm10 += 3;
        // Simulate PM1 as well (if needed)
        // Clamp values to reasonable ranges
        _pm25 = _pm25.clamp(5, 200);
        _pm10 = _pm10.clamp(10, 300);
        // Optionally, simulate PM1
        // _pm1 = (_pm1 ?? 10) + 1;
        // _pm1 = _pm1.clamp(5, 100);
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
      // Optionally, PM1 notification
      // if ((_pm1 ?? 0) > 30 && !_alertedPM1) {
      //   _alertedPM1 = true;
      //   _alertService.showAlert(
      //     title: 'Air Quality Alert',
      //     body: 'PM1 levels are high (${_pm1 ?? 0} μg/m³)!',
      //     level: AlertLevel.warning,
      //     alertType: 'pm1',
      //   );
      // }
    });
  }

  Future<void> _loadFullName() async {
    final prefs = await SharedPreferences.getInstance();
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
    // Log connection attempt for debugging
    print("Starting BLE scan for Nano33BLESense");

    // Scan and connect to the Arduino Nano 33 BLE Sense
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        // Print all found devices for debugging
        print("Found device: ${r.device.name} (${r.device.id})");

        if (r.device.name == "AsthmaGuard") {
          print("Found AsthmaGuard! Connecting...");
          await FlutterBluePlus.stopScan();

          _device = r.device;
          await _device!.connect();
          print("Connected to Nano33BLESense");

          List<BluetoothService> services = await _device!.discoverServices();
          print(
              "Discovered ${services.length} services"); // Use the updated UUIDs for service and characteristics
          final String serviceUuid = "00000000-5ec4-4083-81cd-a10b8d5cf6ec";
          final String tempUuid = "00000001-5ec4-4083-81cd-a10b8d5cf6ec";
          final String pressureUuid = "00000002-5ec4-4083-81cd-a10b8d5cf6ec";
          final String pm25Uuid = "00000003-5ec4-4083-81cd-a10b8d5cf6ec";
          final String pm10Uuid = "00000004-5ec4-4083-81cd-a10b8d5cf6ec";

          for (var service in services) {
            print("Service UUID: ${service.uuid.toString().toLowerCase()}");

            // Check if this is our sensor service
            if (service.uuid.toString().toLowerCase() == serviceUuid) {
              print("Found sensor service");

              for (var characteristic in service.characteristics) {
                final charUuid = characteristic.uuid.toString().toLowerCase();
                print("Characteristic UUID: $charUuid");

                if (charUuid == tempUuid) {
                  print("Found temperature characteristic");
                  _tempChar = characteristic;
                  await _tempChar!.setNotifyValue(true);
                  _tempStream = _tempChar!.value;
                  _tempStream!.listen((value) {
                    // Parse string value instead of binary float
                    final tempValue = _parseStringValue(value);
                    print("Received temperature: $tempValue °C");
                    setState(() {
                      _temperature = tempValue;
                    });
                  });
                }
                if (charUuid == pressureUuid) {
                  print("Found pressure characteristic");
                  _pressureChar = characteristic;
                  await _pressureChar!.setNotifyValue(true);
                  _pressureStream = _pressureChar!.value;
                  _pressureStream!.listen((value) {
                    // Parse string value instead of binary float
                    final pressureValue = _parseStringValue(value);
                    print("Received pressure: $pressureValue hPa");
                    setState(() {
                      _pressure = pressureValue;
                    });
                  });
                }

                // Handle PM2.5 characteristic
                if (charUuid == pm25Uuid) {
                  print("Found PM2.5 characteristic");
                  _pm25Char = characteristic;
                  await _pm25Char!.setNotifyValue(true);
                  _pm25Stream = _pm25Char!.value;
                  _pm25Stream!.listen((value) {
                    // Parse integer value from PM2.5 sensor
                    String stringValue = String.fromCharCodes(value);
                    int? pm25Value = int.tryParse(stringValue);
                    print("Received PM2.5: ${pm25Value ?? 0} μg/m³");
                    setState(() {
                      _pm25 = pm25Value ?? 0;
                    });
                  });
                }

                // Handle PM10 characteristic
                if (charUuid == pm10Uuid) {
                  print("Found PM10 characteristic");
                  _pm10Char = characteristic;
                  await _pm10Char!.setNotifyValue(true);
                  _pm10Stream = _pm10Char!.value;
                  _pm10Stream!.listen((value) {
                    // Parse integer value from PM10 sensor
                    String stringValue = String.fromCharCodes(value);
                    int? pm10Value = int.tryParse(stringValue);
                    print("Received PM10: ${pm10Value ?? 0} μg/m³");
                    setState(() {
                      _pm10 = pm10Value ?? 0;
                    });
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

  // Parse string values from BLE characteristic bytes
  double _parseStringValue(List<int> bytes) {
    try {
      // Convert bytes to string
      String stringValue = String.fromCharCodes(bytes);
      print("Raw string from BLE: '$stringValue'");

      // Try to parse as double
      double? value = double.tryParse(stringValue);

      // Return the parsed value or 0.0 if parsing failed
      return value ?? 0.0;
    } catch (e) {
      print("Error parsing BLE data: $e");
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

    // Calculate relative humidity
    double humidity = (actualVapPres / satVapPres) * 100;

    // Ensure humidity is within 0-100% range
    humidity = humidity.clamp(0.0, 100.0);

    return humidity;
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    // Clean up BLE connection when widget is disposed
    if (_device != null && _device!.isConnected) {
      print("Disconnecting from Nano33BLESense");
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
              title: const Text(
                'Hi, Samuel',
                style: TextStyle(
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
