import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/shelter_model.dart';

class UserShelterMapPage extends StatefulWidget {
  final ll.LatLng userLocation;
  final List<Shelter> shelters;  // ⭐ Passed in from ShelterListPage (already loaded from API)

  const UserShelterMapPage({
    super.key,
    required this.userLocation,
    required this.shelters,
  });

  @override
  State<UserShelterMapPage> createState() => _UserShelterMapPageState();
}

class _UserShelterMapPageState extends State<UserShelterMapPage> {
  late Completer<gmaps.GoogleMapController> _controller;
  final Map<int, List<gmaps.LatLng>> _routeCache = {}; // ⭐ Keyed by shelter.id (int)
  bool _routesLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = Completer();
    _loadAllRoutes();
  }

  // Load real road routes for all shelters
  void _loadAllRoutes() async {
    for (final shelter in widget.shelters) {
      final shelterLatLng = ll.LatLng(shelter.latitude, shelter.longitude);
      final routePoints =
          await _getRoutePoints(widget.userLocation, shelterLatLng);
      if (mounted) {
        setState(() {
          _routeCache[shelter.id!] = routePoints;
        });
      }
    }
    if (mounted) setState(() => _routesLoading = false);
  }

  gmaps.LatLng _toGm(ll.LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  double _calculateDistance(ll.LatLng a, ll.LatLng b) {
    const double r = 6371;
    double dLat = _deg2rad(b.latitude - a.latitude);
    double dLon = _deg2rad(b.longitude - a.longitude);
    double lat1 = _deg2rad(a.latitude);
    double lat2 = _deg2rad(b.latitude);
    double h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Decode Google encoded polyline
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

  // Fetch real route from Google Directions API; falls back to straight line
  Future<List<gmaps.LatLng>> _getRoutePoints(
      ll.LatLng origin, ll.LatLng destination) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=AIzaSyCCKjlPY_0HGJM-Z1ACh-Q3BT6bLMeFfxM';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if ((json['routes'] as List).isNotEmpty) {
          final points =
              json['routes'][0]['overview_polyline']['points'] as String;
          return _decodePolyline(points);
        }
      }
    } catch (e) {
      debugPrint('Directions API error: $e');
    }
    // Straight-line fallback
    return [_toGm(origin), _toGm(destination)];
  }

  @override
  Widget build(BuildContext context) {
    // Centre camera on the average of user + all shelters
    final allLats = [
      widget.userLocation.latitude,
      ...widget.shelters.map((s) => s.latitude),
    ];
    final allLngs = [
      widget.userLocation.longitude,
      ...widget.shelters.map((s) => s.longitude),
    ];
    final center = ll.LatLng(
      allLats.reduce((a, b) => a + b) / allLats.length,
      allLngs.reduce((a, b) => a + b) / allLngs.length,
    );

    final markers = <gmaps.Marker>{};
    final polylines = <gmaps.Polyline>{};

    for (final shelter in widget.shelters) {
      final shelterLatLng = ll.LatLng(shelter.latitude, shelter.longitude);
      final shelterGm = _toGm(shelterLatLng);

      // Capacity display — use 0 if backend fields not populated yet
      final capacity = shelter.capacity ?? 0;
      // Note: `filled` field doesn't exist on the backend yet — show 0
      // until you add filledCount to Shelter entity and ShelterDTO
      const int filled = 0;
      final available = capacity - filled;

      markers.add(gmaps.Marker(
        markerId: gmaps.MarkerId('shelter_${shelter.id}'),
        position: shelterGm,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueBlue),
        infoWindow: gmaps.InfoWindow(
          title: shelter.name,
          snippet: capacity > 0
              ? 'Capacity: $capacity | Available: $available'
              : shelter.address ?? '',
        ),
        onTap: () => _controller.future.then(
            (gm) => gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(shelterGm, 15))),
      ));

      // Route polyline from cache
      if (_routeCache.containsKey(shelter.id)) {
        polylines.add(gmaps.Polyline(
          polylineId: gmaps.PolylineId('route_${shelter.id}'),
          points: _routeCache[shelter.id]!,
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
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueGreen),
      infoWindow: const gmaps.InfoWindow(title: 'Your Location'),
    ));

    // Shelter list sorted by distance
    final sorted = List<Shelter>.from(widget.shelters)
      ..sort((a, b) {
        final dA = _calculateDistance(
            widget.userLocation, ll.LatLng(a.latitude, a.longitude));
        final dB = _calculateDistance(
            widget.userLocation, ll.LatLng(b.latitude, b.longitude));
        return dA.compareTo(dB);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Shelters"),
        backgroundColor: const Color.fromARGB(255, 158, 215, 255),
        actions: [
          if (_routesLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: _toGm(center),
                zoom: 13,
              ),
              markers: markers,
              polylines: polylines,
              onMapCreated: (gm) {
                if (!_controller.isCompleted) _controller.complete(gm);
              },
              myLocationEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
          // Shelter list
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: widget.shelters.isEmpty
                  ? const Center(child: Text('No shelters available'))
                  : ListView.builder(
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final shelter = sorted[index];
                        final shelterLatLng =
                            ll.LatLng(shelter.latitude, shelter.longitude);
                        final distance = _calculateDistance(
                            widget.userLocation, shelterLatLng);
                        final capacity = shelter.capacity ?? 0;
                        const int filled = 0; // see note above
                        final available = capacity - filled;

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (capacity == 0 || available > 0)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            child: Center(
                              child: Text(
                                capacity == 0 ? '?' : available.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
                              Text('Distance: ${distance.toStringAsFixed(2)} km'),
                              if (shelter.address != null)
                                Text(shelter.address!,
                                    style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          onTap: () {
                            _controller.future.then((gm) {
                              gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(
                                  _toGm(shelterLatLng), 15));
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