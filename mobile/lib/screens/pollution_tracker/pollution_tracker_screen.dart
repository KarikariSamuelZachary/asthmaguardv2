import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class PollutionZone {
  final String id;
  final LatLng coordinates;
  final double radius;
  final PollutionData data;

  PollutionZone({
    required this.id,
    required this.coordinates,
    required this.radius,
    required this.data,
  });
}

class PollutionData {
  final int aqi;
  final double pm25;
  final double pm10;

  PollutionData({required this.aqi, required this.pm25, required this.pm10});
}

class PollutionTrackerScreen extends StatefulWidget {
  const PollutionTrackerScreen({super.key});

  @override
  State<PollutionTrackerScreen> createState() => _PollutionTrackerScreenState();
}

class _PollutionTrackerScreenState extends State<PollutionTrackerScreen> {
  PollutionZone? selectedZone;
  final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  final List<PollutionZone> _allPollutionZones = [];

  // Mock data for initial pollution zones
  final List<PollutionZone> _initialPollutionZones = [
    PollutionZone(
      id: '1',
      coordinates: const LatLng(40.6935, -73.9866),
      radius: 500,
      data: PollutionData(aqi: 156, pm25: 75.2, pm10: 142.8),
    ),
    PollutionZone(
      id: '2',
      coordinates: const LatLng(40.6895, -73.9845),
      radius: 300,
      data: PollutionData(aqi: 89, pm25: 35.5, pm10: 82.3),
    ),
    PollutionZone(
      id: '3',
      coordinates: const LatLng(40.6915, -73.9825),
      radius: 400,
      data: PollutionData(aqi: 42, pm25: 12.8, pm10: 38.5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _validateAccessToken();
    _getCurrentLocation();
  }

  void _validateAccessToken() {
    if (accessToken == null) {
      throw Exception(
        'Access token is not available. Please check your .env file.',
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable them.',
            ),
          ),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;

        // Combine initial zones with random green and orange zones
        _allPollutionZones.addAll(_initialPollutionZones);
        if (_currentLocation != null) {
          _allPollutionZones.addAll(
            _generateRandomGreenZones(_currentLocation!, 6, 5),
          );
          _allPollutionZones.addAll(
            _generateRandomOrangeZones(_currentLocation!, 9, 5),
          );
        }
      });

      // Move map to current location after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentLocation != null) {
          _mapController.move(_currentLocation!, 12.0);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      setState(() => _isLoadingLocation = false);
    }
  }

  // Generate random green zones around a central point
  List<PollutionZone> _generateRandomGreenZones(
    LatLng center,
    int count,
    double radiusInKm,
  ) {
    final random = Random();
    final List<PollutionZone> greenZones = [];
    for (int i = 0; i < count; i++) {
      // Generate random coordinates within a radius
      double randomRadius =
          random.nextDouble() * radiusInKm * 1000; // in meters
      double randomAngle = random.nextDouble() * 2 * pi;

      // Convert radius and angle to offset in latitude and longitude
      double latOffset = (randomRadius / 111111) * cos(randomAngle);
      double lonOffset =
          (randomRadius / (111111 * cos(center.latitude * pi / 180))) *
              sin(randomAngle);

      LatLng coordinates = LatLng(
        center.latitude + latOffset,
        center.longitude + lonOffset,
      );

      // Debugging print statement
      debugPrint(
          'Generated Green Zone at: ${coordinates.latitude}, ${coordinates.longitude}');

      greenZones.add(
        PollutionZone(
          id: 'green_${i + 1}',
          coordinates: coordinates,
          radius: 200 + random.nextDouble() * 300, // 200-500m radius
          data: PollutionData(
            aqi: random.nextInt(51), // AQI for green zones (0-50)
            pm25: random.nextDouble() * 12.0,
            pm10: random.nextDouble() * 35.0,
          ),
        ),
      );
    }
    return greenZones;
  }

  // Generate random orange zones around a central point
  List<PollutionZone> _generateRandomOrangeZones(
    LatLng center,
    int count,
    double radiusInKm,
  ) {
    final random = Random();
    final List<PollutionZone> orangeZones = [];
    for (int i = 0; i < count; i++) {
      // Generate random coordinates within a radius
      double randomRadius =
          random.nextDouble() * radiusInKm * 1000; // in meters
      double randomAngle = random.nextDouble() * 2 * pi;

      // Convert radius and angle to offset in latitude and longitude
      double latOffset = (randomRadius / 111111) * cos(randomAngle);
      double lonOffset =
          (randomRadius / (111111 * cos(center.latitude * pi / 180))) *
              sin(randomAngle);

      LatLng coordinates = LatLng(
        center.latitude + latOffset,
        center.longitude + lonOffset,
      );

      debugPrint(
          'Generated Orange Zone at: ${coordinates.latitude}, ${coordinates.longitude}');

      orangeZones.add(
        PollutionZone(
          id: 'orange_${i + 1}',
          coordinates: coordinates,
          radius: 200 + random.nextDouble() * 300, // 200-500m radius
          data: PollutionData(
            aqi: 51 + random.nextInt(100), // AQI for orange zones (51-150)
            pm25: 12.1 + random.nextDouble() * (55.4 - 12.1),
            pm10: 35.1 + random.nextDouble() * (150.4 - 35.1),
          ),
        ),
      );
    }
    return orangeZones;
  }

  // Helper to classify AQI
  String getPollutionLevel(int aqi) {
    if (aqi > 150) return 'high';
    if (aqi > 50) return 'medium';
    return 'low';
  }

  Color getPollutionColor(int aqi) {
    final level = getPollutionLevel(aqi);
    switch (level) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pollution Tracker',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4285F4),
              ),
        ),
      ),
      body: Stack(
        children: [
          if (_isLoadingLocation)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _currentLocation ?? const LatLng(40.6935, -73.9866),
                initialZoom: 12, // Zoom level adjusted for better overview
                onTap: (tapPosition, point) {
                  // Clear selection when tapping the map
                  setState(() => selectedZone = null);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/${isDark ? 'dark' : 'light'}-v10/tiles/{z}/{x}/{y}@2x?access_token={accessToken}',
                  additionalOptions: {'accessToken': accessToken!},
                ),
                CircleLayer(
                  circles: [
                    // Pollution zones
                    ..._allPollutionZones.map(
                      (zone) => CircleMarker(
                        point: zone.coordinates,
                        radius: zone.radius, // Use full radius in meters
                        color: getPollutionColor(
                          zone.data.aqi,
                        ).withOpacity(0.6), // Increased opacity
                        useRadiusInMeter: true,
                        borderStrokeWidth: 2,
                        borderColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    // Current location marker with AQI color if available
                    if (_currentLocation != null)
                      CircleMarker(
                        point: _currentLocation!,
                        radius: 16, // Small circle for user location
                        color: getPollutionColor(
                          _getCurrentLocationAqi(),
                        ).withOpacity(0.8),
                        useRadiusInMeter: false,
                        borderStrokeWidth: 3,
                        borderColor: Colors.white,
                      ),
                  ],
                ),
                // Clickable markers for zones
                MarkerLayer(
                  markers: [
                    // Current location marker
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    // Pollution zone markers
                    ..._allPollutionZones.map(
                      (zone) => Marker(
                        point: zone.coordinates,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => setState(() => selectedZone = zone),
                          child: Container(
                            decoration: BoxDecoration(
                              color: getPollutionColor(zone.data.aqi)
                                  .withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          // Legend Card
          Positioned(
            left: 16,
            bottom: 16,
            child: Card(
              color: isDark
                  ? const Color(0xFF1E1E1E).withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pollution Levels',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4285F4), // Blue
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLegendItem(
                      color: Colors.red,
                      label: 'High Pollution',
                      description: 'AQI > 150',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: Colors.orange,
                      label: 'Medium Pollution',
                      description: 'AQI 51-150',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: Colors.green,
                      label: 'Low Pollution',
                      description: 'AQI 0-50',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pollution Info Card
          if (selectedZone != null)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                color: isDark
                    ? const Color(0xFF1E1E1E).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pollution Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDataItem(
                            'AQI',
                            selectedZone!.data.aqi.toString(),
                            isDark,
                          ),
                          const SizedBox(width: 16),
                          _buildDataItem(
                            'PM2.5',
                            selectedZone!.data.pm25.toString(),
                            isDark,
                          ),
                          const SizedBox(width: 16),
                          _buildDataItem(
                            'PM10',
                            selectedZone!.data.pm10.toString(),
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _currentLocation != null
          ? FloatingActionButton(
              onPressed: () {
                _mapController.move(_currentLocation!, 15.0);
              },
              backgroundColor: const Color(0xFF4285F4),
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String description,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataItem(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get AQI at current location (find nearest zone or default to green)
  int _getCurrentLocationAqi() {
    if (_currentLocation == null || _allPollutionZones.isEmpty) return 0;
    final Distance distance = Distance();
    PollutionZone? nearest;
    double minDist = double.infinity;
    for (final zone in _allPollutionZones) {
      final dist = distance(_currentLocation!, zone.coordinates);
      if (dist < minDist) {
        minDist = dist;
        nearest = zone;
      }
    }
    if (nearest != null && minDist <= nearest.radius) {
      return nearest.data.aqi;
    }
    return 0;
  }
}
