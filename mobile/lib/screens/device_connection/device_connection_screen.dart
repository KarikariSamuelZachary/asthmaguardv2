import 'package:app_settings/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (scanStatus.isGranted &&
        connectStatus.isGranted &&
        locationStatus.isGranted) {
      FlutterBluePlus.isScanning.listen((scanning) {
        setState(() {
          isScanning = scanning;
        });
      });
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          scanResults = results;
        });
      });
      _startScan();
    } else {
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Bluetooth and Location permissions are required to scan for devices. Please enable them in system settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppSettings.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _startScan() {
    setState(() {
      scanResults.clear();
      isScanning = true;
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    Future.delayed(const Duration(seconds: 4), () {
      FlutterBluePlus.stopScan();
      setState(() {
        isScanning = false;
      });
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Connection',
          style: TextStyle(
            color: Color(0xFF4285F4), // Blue
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nearby BLE Devices',
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: Icon(isScanning ? Icons.sync : Icons.refresh),
                  onPressed: isScanning ? null : _startScan,
                ),
              ],
            ),
          ),
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          // Always show AsthmaGuard as connected
          ListTile(
            leading: const Icon(Icons.bluetooth, color: Color(0xFF4285F4)),
            title: const Text('AsthmaGuard',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('00:11:22:33:44:55'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 6),
                Text('Connected', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: scanResults.isEmpty && !isScanning
                ? Center(child: Text('No devices found.'))
                : ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      final result = scanResults[index];
                      final device = result.device;
                      return StreamBuilder<BluetoothConnectionState>(
                        stream: device.connectionState,
                        initialData: BluetoothConnectionState.disconnected,
                        builder: (context, snapshot) {
                          final isConnected = snapshot.data ==
                              BluetoothConnectionState.connected;
                          return ListTile(
                            title: Text(
                              device.name.isNotEmpty
                                  ? device.name
                                  : 'Unknown Device',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(device.id.toString()),
                            trailing: isConnected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.check_circle,
                                          color: Colors.green),
                                      SizedBox(width: 6),
                                      Text('Connected',
                                          style:
                                              TextStyle(color: Colors.green)),
                                    ],
                                  )
                                : ElevatedButton(
                                    child: const Text('Connect'),
                                    onPressed: () => _connectToDevice(device),
                                  ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
