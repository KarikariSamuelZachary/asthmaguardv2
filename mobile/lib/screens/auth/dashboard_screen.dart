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
  double? _temperature;
  double? _pressure;
  int? _pm25; // For PM2.5 readings
  int? _pm10; // For PM10 readings
  BluetoothDevice? _device;
  BluetoothCharacteristic? _tempChar;
  BluetoothCharacteristic? _pressureChar;
  BluetoothCharacteristic? _pm25Char; // For PM2.5 characteristic
  BluetoothCharacteristic? _pm10Char; // For PM10 characteristic
  Stream<List<int>>? _tempStream;
  Stream<List<int>>? _pressureStream;
  Stream<List<int>>? _pm25Stream; // For PM2.5 stream
  Stream<List<int>>? _pm10Stream; // For PM10 stream;

  @override
  void initState() {
    super.initState();
    _connectAndSubscribeBLE();
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
  double _calculateApproximateHumidity(double? temperature, double? pressure) {
    if (temperature == null || pressure == null) return 0.0;

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
    double? humidity = (_temperature != null && _pressure != null)
        ? _calculateApproximateHumidity(_temperature, _pressure)
        : null;
    final List<Widget> _screens = [
      _HomeDashboard(
        temperature: _temperature,
        pressure: _pressure,
        humidity: humidity,
        pm25: _pm25,
        pm10: _pm10,
      ),
      const PollutionTrackerScreen(),
      const LiveSensorScreen(),
      const HealthReportScreen(),
      const SettingsTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.withOpacity(0.85),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF26A69A), Color(0xFF80CBC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, User',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 48),
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.teal.shade700),
            ),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Log out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
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
}

// Extracted Home dashboard content to a separate widget for cleaner tab switching
class _HomeDashboard extends StatelessWidget {
  final double? temperature;
  final double? pressure;
  final double? humidity;
  final int? pm25;
  final int? pm10;
  const _HomeDashboard({
    Key? key,
    this.temperature,
    this.pressure,
    this.humidity,
    this.pm25,
    this.pm10,
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
                        color: Colors.teal.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_today,
                          color: Colors.teal, size: 28),
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
                                  : Colors.teal.shade700,
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
                    color: Colors.teal.shade800,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount:
                  2, // Changed to 2 columns for better layout with 4 tiles
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                SensorTile(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: temperature != null
                      ? '${temperature!.toStringAsFixed(2)} °C'
                      : 'N/A',
                  color: Colors.orangeAccent,
                ),
                SensorTile(
                  icon: Icons.speed,
                  label: 'Pressure',
                  value: pressure != null
                      ? '${pressure!.toStringAsFixed(2)} hPa'
                      : 'N/A',
                  color: Colors.purple,
                ),
                SensorTile(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: humidity != null
                      ? '${humidity!.toStringAsFixed(2)}%'
                      : 'N/A',
                  color: Colors.blue,
                ),
                SensorTile(
                  icon: Icons.air,
                  label: 'Air Quality',
                  value: pm25 != null ? '${pm25} μg/m³' : 'N/A',
                  color: Colors.green, // Will update to dynamic color later
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Emergency Button
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    splashColor: Colors.redAccent.withOpacity(0.2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyContactsScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'EMERGENCY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Tools Grid
            Text(
              'Your Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
            ),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 1.1,
              children: [
                DashboardCard(
                  context,
                  title: 'Health Tips',
                  icon: Icons.lightbulb_outline,
                  imagePath: 'assets/images/health_tips.png',
                  color: Colors.orangeAccent,
                  onTap: () => Navigator.pushNamed(context, '/health-tips'),
                ),
                DashboardCard(
                  context,
                  title: 'Wellness Hub',
                  icon: Icons.self_improvement,
                  imagePath: 'assets/images/wellness_hub.png',
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WellnessHub()),
                  ),
                ),
                DashboardCard(
                  context,
                  title: 'BMR Calculator',
                  icon: Icons.calculate,
                  imagePath: 'assets/images/bmr_calculator.png',
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BMRCalculator()),
                  ),
                ),
                DashboardCard(
                  context,
                  title: 'Exercise Routines',
                  icon: Icons.fitness_center,
                  imagePath: 'assets/images/exercise_routines.png',
                  color: Colors.green,
                  onTap: () =>
                      Navigator.pushNamed(context, '/exercise-routines'),
                ),
                DashboardCard(
                  context,
                  title: 'Medication Tracker',
                  icon: Icons.medication,
                  imagePath: 'assets/images/medication_tracker.png',
                  color: Colors.purple,
                  onTap: () =>
                      Navigator.pushNamed(context, '/medication-tracker'),
                ),
                DashboardCard(
                  context,
                  title: 'Log Symptoms',
                  icon: Icons.sick,
                  imagePath: 'assets/images/log_symptoms.png',
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
  const DashboardCard(
    this.context, {
    super.key,
    required this.title,
    required this.icon,
    required this.imagePath,
    required this.color,
    required this.onTap,
  });

  final BuildContext context;
  final String title;
  final IconData icon;
  final String imagePath;
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
                  Image.asset(
                    imagePath,
                    height: 48,
                    width: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(icon, size: 40, color: color);
                    },
                  ),
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
