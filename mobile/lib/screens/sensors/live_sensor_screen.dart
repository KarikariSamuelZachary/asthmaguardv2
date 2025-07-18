import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class LiveSensorScreen extends StatefulWidget {
  const LiveSensorScreen({super.key});

  @override
  State<LiveSensorScreen> createState() => _LiveSensorScreenState();
}

class _LiveSensorScreenState extends State<LiveSensorScreen> {
  BluetoothDevice? _device;  Map<String, dynamic> _sensorData = {
    'temperature': null,
    'pressure': null,
    'humidity': null,
    'pm1': null,
    'pm25': null,
    'pm10': null,
  };

  List<Map<String, dynamic>> _historicalData = [];
  Timer? _updateTimer;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';

  // UUIDs for BLE service and characteristics
  final String _serviceUuid = "00000000-5ec4-4083-81cd-a10b8d5cf6ec";
  final String _tempUuid = "00000001-5ec4-4083-81cd-a10b8d5cf6ec";
  final String _pressureUuid = "00000002-5ec4-4083-81cd-a10b8d5cf6ec";
  final String _pm25Uuid = "00000003-5ec4-4083-81cd-a10b8d5cf6ec";
  final String _pm10Uuid = "00000004-5ec4-4083-81cd-a10b8d5cf6ec";
  @override
  void initState() {
    super.initState();
    _connectToBLEDevice();

    // Set up timer to save historical data every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _addHistoricalDataPoint();
    });
    
    // Add a shorter timer to ensure PM values are updated properly
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _updatePMValues();
      }
    });
  }
    // Helper method to ensure PM1 is calculated whenever PM2.5 and PM10 are available
  void _updatePMValues() {
    // Only calculate PM1 if both PM2.5 and PM10 have actual data
    if (_sensorData['pm25'] != null && _sensorData['pm10'] != null) {
      setState(() {
        _sensorData['pm1'] = _estimatePM1(_sensorData['pm25'], _sensorData['pm10']);
        print("PM values updated in timer: PM1=${_sensorData['pm1']}, PM2.5=${_sensorData['pm25']}, PM10=${_sensorData['pm10']}");
      });
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _updateTimer?.cancel();
    if (_device != null && _isConnected) {
      _device!.disconnect();
    }
    super.dispose();
  }  // Add a data point to historical data for graphing
  void _addHistoricalDataPoint() {
    // Debug print current sensor values
    print("Adding historical data point - current sensor values:");
    print("PM1: ${_sensorData['pm1']}");
    print("PM2.5: ${_sensorData['pm25']}");
    print("PM10: ${_sensorData['pm10']}");
    
    // Ensure PM1 is calculated if we have PM2.5 data
    if (_sensorData['pm25'] != null && _sensorData['pm10'] != null && _sensorData['pm1'] == null) {
      _sensorData['pm1'] = _estimatePM1(_sensorData['pm25'], _sensorData['pm10']);
    }
    
    // Only add data if we have actual sensor readings
    if (_sensorData['temperature'] != null || _sensorData['pm25'] != null) {
      setState(() {
        _historicalData.add({
          'timestamp': DateTime.now(),
          'temperature': _sensorData['temperature'],
          'pressure': _sensorData['pressure'],
          'humidity': _sensorData['humidity'],
          'pm1': _sensorData['pm1'],
          'pm25': _sensorData['pm25'],
          'pm10': _sensorData['pm10'],
        });
  
        // Keep only the last 120 data points (1 hour at 30-second intervals)
        if (_historicalData.length > 120) {
          _historicalData.removeAt(0);
        }
      });
    }
  }
  Future<void> _connectToBLEDevice() async {
    setState(() {
      _connectionStatus = 'Scanning...';
    });

    try {
      print("LiveSensorScreen: Starting BLE scan for AsthmaGuard");
      // Start scanning for BLE devices
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) async {
        print("LiveSensorScreen: Found ${results.length} BLE devices");
        for (ScanResult r in results) {
          print("LiveSensorScreen: Device: ${r.device.name} (${r.device.id})");
          if (r.device.name == "AsthmaGuard") {
            print("LiveSensorScreen: Found AsthmaGuard! Connecting...");
            await FlutterBluePlus.stopScan();

            setState(() {
              _connectionStatus = 'Found device. Connecting...';
            });

            _device = r.device;
            await _device!.connect();
            print("LiveSensorScreen: Connected to AsthmaGuard");

            setState(() {
              _isConnected = true;
              _connectionStatus = 'Connected to Nano33BLESense';
            });

            // Discover services and set up notifications
            print("LiveSensorScreen: Setting up BLE notifications");
            await _setupCharacteristicNotifications();
            break;
          }
        }
      });

      // If no device found after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected) {
          setState(() {
            _connectionStatus = 'No device found. Pull to refresh.';
          });
        }
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection error: $e';
        _isConnected = false;
      });
    }
  }

  Future<void> _setupCharacteristicNotifications() async {
    try {
      List<BluetoothService> services = await _device!.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == _serviceUuid) {
          for (var characteristic in service.characteristics) {
            final charUuid = characteristic.uuid.toString().toLowerCase();            if (charUuid == _tempUuid) {
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                final temp = _parseStringValue(value);
                print('LiveSensorScreen: Raw temp string: ' +
                    String.fromCharCodes(value));
                print('LiveSensorScreen: Parsed temp: ' + temp.toString());
                if (!mounted) return;
                setState(() {
                  _sensorData['temperature'] = temp;
                  print('UPDATED temperature state to: $temp');
                  if (_sensorData['pressure'] != null &&
                      _sensorData['temperature'] != null) {
                    _sensorData['humidity'] = _calculateApproximateHumidity(
                      _sensorData['temperature'],
                      _sensorData['pressure'],
                    );
                    print('UPDATED humidity state to: ${_sensorData['humidity']}');
                  }
                });
              });
            }

            if (charUuid == _pressureUuid) {
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                final pressure = _parseStringValue(value);
                print('LiveSensorScreen: Raw pressure string: ' +
                    String.fromCharCodes(value));
                print('LiveSensorScreen: Parsed pressure: ' +
                    pressure.toString());
                if (!mounted) return;
                setState(() {
                  _sensorData['pressure'] = pressure;
                  if (_sensorData['pressure'] != null &&
                      _sensorData['temperature'] != null) {
                    _sensorData['humidity'] = _calculateApproximateHumidity(
                      _sensorData['temperature'],
                      _sensorData['pressure'],
                    );
                  }
                });
              });
            }            if (charUuid == _pm25Uuid) {
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                String rawString = String.fromCharCodes(value);
                print('LiveSensorScreen: Raw PM2.5 string: "$rawString"');
                final pm25 = _parseIntValue(value);
                print('LiveSensorScreen: Parsed PM2.5: $pm25');
                
                if (!mounted) return;
                setState(() {
                  _sensorData['pm25'] = pm25;
                  print('UPDATED PM2.5 state to: $pm25');
                });
              });
            }            if (charUuid == _pm10Uuid) {
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                String rawString = String.fromCharCodes(value);
                print('LiveSensorScreen: Raw PM10 string: "$rawString"');
                final pm10 = _parseIntValue(value);
                print('LiveSensorScreen: Parsed PM10: $pm10');
                
                if (!mounted) return;
                setState(() {
                  _sensorData['pm10'] = pm10;
                  print('UPDATED PM10 state to: $pm10');
                  
                  // Calculate PM1 after both PM10 and PM2.5 are updated
                  if (_sensorData['pm25'] != null) {
                    _sensorData['pm1'] = _estimatePM1(_sensorData['pm25'], pm10);
                    print('UPDATED PM1 state to: ${_sensorData['pm1']}');
                  }
                });
              });
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Service discovery error: $e';
      });
    }
  }
  // Parse string values from BLE characteristic bytes
  double? _parseStringValue(List<int> bytes) {
    try {
      String stringValue = String.fromCharCodes(bytes);
      print('Raw BLE string value: "$stringValue"');
      
      // Trim any whitespace or non-printable characters
      stringValue = stringValue.trim();
      
      // Try to parse as double
      double? value = double.tryParse(stringValue);
      
      // Return null if parsing failed to show N/A in the UI
      print('Parsed double value: $value');
      return value;
    } catch (e) {
      print('Error parsing string value: $e');
      return null;
    }
  }  // Parse integer values from BLE characteristic bytes
  int? _parseIntValue(List<int> bytes) {
    try {
      String stringValue = String.fromCharCodes(bytes);
      print('Raw BLE integer string: "$stringValue"');
      
      // Trim any whitespace or non-printable characters
      stringValue = stringValue.trim();
      
      // Check if string is empty after trimming
      if (stringValue.isEmpty) {
        print('Empty string received, returning null');
        return null;
      }
      
      // Try to parse as int
      int? value = int.tryParse(stringValue);
      
      // Return null if parsing failed to show N/A in the UI
      print('Parsed integer value: $value');
      return value;
    } catch (e) {
      print('Error parsing integer value: $e');
      return null;
    }
  }
  // Calculate approximate humidity using Magnus formula
  double? _calculateApproximateHumidity(double? temperature, double? pressure) {
    if (temperature == null || pressure == null) return null;

    const a = 17.27;
    const b = 237.7; // °C
    final satVapPres = 6.112 * math.exp((a * temperature) / (b + temperature));
    final actualVapPres = satVapPres * (1 - ((1013 - pressure) / 100) * 0.1);
    double humidity = (actualVapPres / satVapPres) * 100;
    humidity = humidity.clamp(0.0, 100.0);

    return humidity;
  }  // Estimate PM1.0 from PM2.5 and PM10 (approximate)
  int? _estimatePM1(int? pm25, int? pm10) {
    if (pm25 == null || pm10 == null) {
      print("Unable to estimate PM1 - null values: PM2.5: $pm25, PM10: $pm10");
      return null;
    }
    
    // This is a rough estimation - PM1 is typically 40-60% of PM2.5 in many environments
    int estimate = (pm25 * 0.5).round();
    print("Estimated PM1: $estimate (from PM2.5: $pm25, PM10: $pm10)");
    return estimate;
  }

  // Calculate Air Quality Index from PM2.5
  String _getAqiCategory(int? pm25) {
    if (pm25 == null) return 'Unknown';

    if (pm25 <= 12) return 'Good';
    if (pm25 <= 35) return 'Moderate';
    if (pm25 <= 55) return 'Unhealthy for Sensitive Groups';
    if (pm25 <= 150) return 'Unhealthy';
    if (pm25 <= 250) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _getAqiColor(int? pm25) {
    if (pm25 == null) return Colors.grey;

    if (pm25 <= 12) return Colors.green;
    if (pm25 <= 35) return Colors.yellow;
    if (pm25 <= 55) return Colors.orange;
    if (pm25 <= 150) return Colors.red;
    if (pm25 <= 250) return Colors.purple;
    return Colors.brown;
  }  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Debug prints for sensor values
    print("Live Sensor Screen Build - Current Sensor Values:");
    print("Temperature: ${_sensorData['temperature']}");
    print("Pressure: ${_sensorData['pressure']}");
    print("Humidity: ${_sensorData['humidity']}");
    print("PM1: ${_sensorData['pm1']}");
    print("PM2.5: ${_sensorData['pm25']}");
    print("PM10: ${_sensorData['pm10']}");
    
    // Ensure PM1 is calculated if we have PM2.5 and PM10 data but PM1 is null
    if (_sensorData['pm25'] != null && _sensorData['pm10'] != null && _sensorData['pm1'] == null) {
      _sensorData['pm1'] = _estimatePM1(_sensorData['pm25'], _sensorData['pm10']);
      print("Recalculated PM1 during build: ${_sensorData['pm1']}");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Sensor Data',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4285F4),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _connectToBLEDevice,
            tooltip: 'Reconnect to sensor',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _connectToBLEDevice();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection status card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          _isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          color: _isConnected ? Colors.blue : Colors.grey,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: $_connectionStatus',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Air Quality Metrics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                ),
                const SizedBox(height: 16),

                // Air Quality Status Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _getAqiColor(_sensorData['pm25']),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getAqiColor(_sensorData['pm25'])
                                    .withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.air,
                                color: _getAqiColor(_sensorData['pm25']),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Air Quality',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getAqiCategory(_sensorData['pm25']),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _getAqiColor(_sensorData['pm25']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildParticleItem('PM1.0', _sensorData['pm1']),
                            _buildParticleItem('PM2.5', _sensorData['pm25']),
                            _buildParticleItem('PM10', _sensorData['pm10']),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Environmental Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                ),
                const SizedBox(
                    height: 16), // Environmental data cards in a grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [                    _buildSensorCard(
                      icon: Icons.thermostat,
                      title: 'Temperature',
                      value: _sensorData['temperature'] != null
                          ? _sensorData['temperature'].toStringAsFixed(1)
                          : 'N/A',
                      unit: '°C',
                      color: Colors.orangeAccent,
                    ),                    _buildSensorCard(
                      icon: Icons.compress,
                      title: 'Pressure',
                      value: _sensorData['pressure'] != null
                          ? _sensorData['pressure'].toStringAsFixed(1)
                          : 'N/A',
                      unit: 'hPa',
                      color: Colors.purpleAccent,
                    ),                    _buildSensorCard(
                      icon: Icons.water_drop,
                      title: 'Humidity',
                      value: _sensorData['humidity'] != null
                          ? _sensorData['humidity'].toStringAsFixed(1)
                          : 'N/A',
                      unit: '%',
                      color: Colors.blueAccent,
                    ),                    _buildSensorCard(
                      icon: Icons.air,
                      title: 'Air Quality',
                      value: _sensorData['pm25'] != null
                          ? _sensorData['pm25'].toString()
                          : 'N/A',
                      unit: 'μg/m³',
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Health recommendation based on air quality
                if (_sensorData['pm25'] != null)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.health_and_safety,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Health Recommendation',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getHealthRecommendation(_sensorData['pm25']),
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }  Widget _buildParticleItem(String label, int? value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value != null ? '$value μg/m³' : 'N/A',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    // Format display with unit only if value is not N/A
    final displayValue = value == 'N/A' ? 'N/A' : '$value $unit';
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHealthRecommendation(int? pm25) {
    if (pm25 == null) return 'No data available';

    if (pm25 <= 12) {
      return 'Air quality is good. Ideal conditions for outdoor activities and exercise.';
    } else if (pm25 <= 35) {
      return 'Air quality is moderate. Consider reducing prolonged outdoor activities if you have respiratory conditions.';
    } else if (pm25 <= 55) {
      return 'Air quality is unhealthy for sensitive groups. People with asthma should limit outdoor exertion and keep quick-relief medicine handy.';
    } else if (pm25 <= 150) {
      return 'Air quality is unhealthy. Limit outdoor activities and consider wearing a mask. Keep your rescue inhaler close by.';
    } else if (pm25 <= 250) {
      return 'Air quality is very unhealthy. Avoid outdoor activities. People with asthma should stay indoors and ensure proper medication.';
    } else {
      return 'Air quality is hazardous. Stay indoors with windows closed. Use air purifiers if available. Have emergency medication ready.';
    }
  }
}
