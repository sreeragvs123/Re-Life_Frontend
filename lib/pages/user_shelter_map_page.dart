import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/shelter.dart';
import '../data/shelter_data.dart';

class UserShelterMapPage extends StatefulWidget {
  final ll.LatLng userLocation;

  const UserShelterMapPage({
    super.key,
    required this.userLocation,
  });

  @override
  State<UserShelterMapPage> createState() => _UserShelterMapPageState();
}

class _UserShelterMapPageState extends State<UserShelterMapPage> {
  late Completer<gmaps.GoogleMapController> _controller;
  final Map<String, List<gmaps.LatLng>> _routeCache = {};
  bool _routesLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = Completer();
    _loadAllRoutes();
  }

  // Load routes for all shelters
  void _loadAllRoutes() async {
    for (final shelter in shelters) {
      final shelterLatLng = ll.LatLng(shelter.latitude, shelter.longitude);
      final routePoints = await _getRoutePoints(widget.userLocation, shelterLatLng);
      setState(() {
        _routeCache['${shelter.id}'] = routePoints;
      });
    }
    setState(() {
      _routesLoading = false;
    });
  }

  // Convert latlong2 LatLng -> google_maps_flutter LatLng
  gmaps.LatLng _toGm(ll.LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  // Calculate distance in km using haversine formula
  double _calculateDistance(ll.LatLng a, ll.LatLng b) {
    const double earthRadius = 6371; // km
    double dLat = _deg2rad(b.latitude - a.latitude);
    double dLon = _deg2rad(b.longitude - a.longitude);
    double lat1 = _deg2rad(a.latitude);
    double lat2 = _deg2rad(b.latitude);

    double haversine =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(haversine), sqrt(1 - haversine));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Decode polyline from Google Directions API
  List<gmaps.LatLng> _decodePolyline(String encoded) {
    List<gmaps.LatLng> poly = [];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(gmaps.LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  // Fetch real route from Google Directions API
  Future<List<gmaps.LatLng>> _getRoutePoints(ll.LatLng origin, ll.LatLng destination) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=AIzaSyCCKjlPY_0HGJM-Z1ACh-Q3BT6bLMeFfxM';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['routes'].isNotEmpty) {
          final points = json['routes'][0]['overview_polyline']['points'];
          return _decodePolyline(points);
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    
    // Fallback to straight line if API fails
    return [_toGm(origin), _toGm(destination)];
  }

  @override
  Widget build(BuildContext context) {
    // Calculate map center (average of all shelter locations and user)
    double avgLat = (widget.userLocation.latitude +
            shelters.fold<double>(0, (sum, s) => sum + s.latitude) / shelters.length) /
        2;
    double avgLon = (widget.userLocation.longitude +
            shelters.fold<double>(0, (sum, s) => sum + s.longitude) / shelters.length) /
        2;
    final center = ll.LatLng(avgLat, avgLon);

    final initialCamera = gmaps.CameraPosition(
      target: _toGm(center),
      zoom: 13,
    );

    // Build markers and polylines for Google Maps
    final markers = <gmaps.Marker>{};
    final polylines = <gmaps.Polyline>{};

    // Add user-to-shelter routes and shelter markers
    for (final shelter in shelters) {
      final shelterLatLng = ll.LatLng(shelter.latitude, shelter.longitude);
      final shelterGm = _toGm(shelterLatLng);

      // Shelter marker
      markers.add(gmaps.Marker(
        markerId: gmaps.MarkerId(shelter.id),
        position: shelterGm,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
        infoWindow: gmaps.InfoWindow(
          title: shelter.name,
          snippet:
              "Capacity: ${shelter.capacity} | Filled: ${shelter.filled} | Available: ${shelter.capacity - shelter.filled}",
        ),
        onTap: () {
          _controller.future.then((gm) =>
              gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(shelterGm, 15)));
        },
      ));

      // Real route from user to shelter (from cache)
      if (_routeCache.containsKey(shelter.id)) {
        final routePoints = _routeCache[shelter.id]!;
        polylines.add(gmaps.Polyline(
          polylineId: gmaps.PolylineId('user_to_${shelter.id}'),
          points: routePoints,
          color: Colors.green.withOpacity(0.7),
          width: 4,
          geodesic: true,
        ));
      }
    }

    // User marker
    markers.add(gmaps.Marker(
      markerId: const gmaps.MarkerId('__user__'),
      position: _toGm(widget.userLocation),
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
      infoWindow: const gmaps.InfoWindow(title: 'Your Location'),
    ));

    // Sort shelters by distance
    final sortedShelters = List<Shelter>.from(shelters);
    sortedShelters.sort((a, b) {
      final distA = _calculateDistance(
        widget.userLocation,
        ll.LatLng(a.latitude, a.longitude),
      );
      final distB = _calculateDistance(
        widget.userLocation,
        ll.LatLng(b.latitude, b.longitude),
      );
      return distA.compareTo(distB);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Shelters"),
        backgroundColor: const Color.fromARGB(255, 158, 215, 255),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: gmaps.GoogleMap(
              initialCameraPosition: initialCamera,
              markers: markers,
              polylines: polylines,
              onMapCreated: (gm) {
                if (!_controller.isCompleted) _controller.complete(gm);
              },
              myLocationEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
          // Shelter list with distances and capacity
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: sortedShelters.length,
                itemBuilder: (context, index) {
                  final shelter = sortedShelters[index];
                  final shelterLatLng = ll.LatLng(shelter.latitude, shelter.longitude);
                  final distance = _calculateDistance(widget.userLocation, shelterLatLng);
                  final available = shelter.capacity - shelter.filled;
                  final capacityPercent = (shelter.filled / shelter.capacity * 100).toStringAsFixed(0);

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: available > 0 ? Colors.green : Colors.red,
                      ),
                      child: Center(
                        child: Text(
                          available.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    title: Text(
                      shelter.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Distance: ${distance.toStringAsFixed(2)} km"),
                        Text(
                          "Capacity: ${shelter.filled}/${shelter.capacity} ($capacityPercent%) | Available: $available",
                          style: TextStyle(
                            fontSize: 12,
                            color: available > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _controller.future.then((gm) {
                        final shelterGm = _toGm(shelterLatLng);
                        gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(shelterGm, 15));
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}