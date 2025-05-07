import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
// import 'package:polyline/polyline.dart' as polyline;

import '../widgets/circular_value_widget.dart';

class KilocalculatorScreen extends StatefulWidget {
  @override
  State<KilocalculatorScreen> createState() => _KilocalculatorScreenState();
}

class _KilocalculatorScreenState extends State<KilocalculatorScreen> {
  bool isLoading = true;
  LatLng? currentLocation;
  List<LatLng> routePoints = [];
  List<LatLng> routeCoordinates = [];
  double totalDistance = 0.0;
  Position? lastPosition;
  StreamSubscription<Position>? positionStream;
  bool isStarted = false;
  String? _selectedCityType;
  Timer? _routeUpdateTimer;
  final String _osrmUrl = 'https://router.project-osrm.org/route/v1/driving/';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _routeUpdateTimer?.cancel();
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _showStopConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text('Confirm Stop'),
          content: const Text('Are you sure you want to stop this trip?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Stop'),
              onPressed: () {
                _stopTrip();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _stopTrip() {
    _routeUpdateTimer?.cancel();
    positionStream?.cancel();
    setState(() {
      isStarted = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      isLoading = false;
    });
  }

  void _startTracking() {
    setState(() {
      isStarted = true;
      routePoints.clear();
      routeCoordinates.clear();
      totalDistance = 0.0;
    });

    // Add initial point
    if (currentLocation != null) {
      routePoints.add(currentLocation!);
      routeCoordinates.add(currentLocation!);
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10, // Update every 10 meters
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      final newPoint = LatLng(position.latitude, position.longitude);
      
      setState(() {
        currentLocation = newPoint;
      });

      if (routeCoordinates.isNotEmpty) {
        await _getRouteCoordinates(routeCoordinates.last, newPoint);
      }
      routeCoordinates.add(newPoint);
    });

    _routeUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (routeCoordinates.length >= 2) {
        await _getRouteCoordinates(routeCoordinates.first, routeCoordinates.last);
      }
    });
  }

  Future<void> _getRouteCoordinates(LatLng start, LatLng end) async {
    try {
      final response = await http.get(
        Uri.parse('$_osrmUrl${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          
          // Coordinates are in GeoJSON format [longitude, latitude]
          final coordinates = (geometry['coordinates'] as List)
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
          
          final distance = data['routes'][0]['distance'] / 1000; // Convert to km
          
          setState(() {
            routePoints = coordinates;
            totalDistance = distance;
          });
          return;
        }
      }
    } catch (e) {
      print('Error getting route: $e');
    }
    
    setState(() {
      routePoints = [start, end];
      totalDistance = const Distance().as(LengthUnit.Kilometer, start, end);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularValueWidget(label: 'KM', value: totalDistance.toStringAsFixed(2)),
            CircularValueWidget(label: 'KS', value: '0.00'),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: "intra_city",
                          groupValue: _selectedCityType,
                          onChanged: (value) {
                            setState(() {
                              _selectedCityType = value;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                        const Text(
                          "မြို့တွင်း",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                           Radio<String>(
                          value: "inter_city",
                          groupValue: _selectedCityType,
                          onChanged: (value) {
                            setState(() {
                              _selectedCityType = value;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                      
                        const Text(
                          "မြို့ပြင်",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Column(
                children: [
                  Icon(Icons.payment, size: 30, color: Colors.white),
                  SizedBox(height: 5),
                  Text("၀န်ဆောင်ခ", style: TextStyle(color: Colors.white)),
                ],
              ),
              SizedBox(width: 20),
              Column(
                children: [
                  Icon(Icons.play_arrow, size: 30, color: Colors.white),
                  SizedBox(height: 5),
                  Text("စောင့်ဆိုင်းချိန်",
                      style: TextStyle(color: Colors.white)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            center: currentLocation,
                            zoom: 18.0,
                            onPositionChanged: (MapPosition position, bool hasGesture) {
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.go_yangon_mobile',
                            ),
                            if (routePoints.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: routePoints,
                                    color: Colors.blue,
                                    strokeWidth: 4.0,
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                if (currentLocation != null)
                                  Marker(
                                    width: 40.0,
                                    height: 40.0,
                                    point: currentLocation!,
                                    builder: (ctx) => const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 30),
                                  ),
                                if (routePoints.isNotEmpty)
                                  Marker(
                                    width: 30.0,
                                    height: 30.0,
                                    point: routePoints.first,
                                    builder: (ctx) => const Icon(
                                      Icons.location_pin,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isStarted ? Colors.red : Colors.orange[800],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                ),
                                onPressed: () {
                                  if (isStarted) {
                                    _showStopConfirmation();
                                  } else {
                                    _startTracking();
                                  }
                                },
                                child: Text(
                                  isStarted ? 'Stop' : 'Start',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )),
                      ],
                    )),
        ),
      ],
    );
  }
}