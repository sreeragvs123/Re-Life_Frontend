// lib/pages/evacuation_map_page.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../../models/evacuation_route.dart';
import '../../data/evacuation_routes_data.dart';
import 'map_picker_page.dart';

class EvacuationMapPage extends StatefulWidget {
  final bool isAdmin; // true for admin
  const EvacuationMapPage({super.key, this.isAdmin = false});

  @override
  State<EvacuationMapPage> createState() => _EvacuationMapPageState();
}

class _EvacuationMapPageState extends State<EvacuationMapPage> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  ll.LatLng? userStartPoint;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askUserLocation());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Helper: convert latlong2 LatLng -> google_maps_flutter LatLng
  gmaps.LatLng _toGm(ll.LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  // Ask user for starting location
  void _askUserLocation() async {
    if (!mounted) return;
    final picked = await Navigator.of(context).push<ll.LatLng>(
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );
    if (picked != null && mounted) {
      setState(() => userStartPoint = picked);
    }
  }

  // Admin adds a new route via dialog
  void _showAddRouteDialog() async {
    _nameController.clear();

    final fallback = ll.LatLng(8.8932, 76.6141);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Destination Shelter"),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Shelter Name",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final picked = await Navigator.of(context).push<ll.LatLng>(
                      MaterialPageRoute(builder: (context) => const MapPickerPage()),
                    );
                    if (picked != null && mounted) {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a shelter name")),
                        );
                        _showAddRouteDialog(); // Re-open dialog
                        return;
                      }

                      setState(() {
                        evacuationRoutes.add(EvacuationRoute(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          path: [userStartPoint ?? fallback, picked],
                          shelterLocation: picked,
                          shelterId: '',
                        ));
                      });

                      // Move main map camera to the newly added shelter
                      final gm = await _controller.future;
                      gm.animateCamera(gmaps.CameraUpdate.newLatLng(_toGm(picked)));
                    }
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Pick Location on Map'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Admin deletes a route
  void _deleteRoute(String id) {
    setState(() {
      evacuationRoutes.removeWhere((route) => route.id == id);
    });
  }

  // Distance calculation (haversine)
  double _distanceInKm(ll.LatLng a, ll.LatLng b) {
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

  @override
  Widget build(BuildContext context) {
    final fallback = ll.LatLng(8.8932, 76.6141);
    final initialCenter = userStartPoint ?? (evacuationRoutes.isNotEmpty ? evacuationRoutes[0].path.first : fallback);

    final initialCamera = gmaps.CameraPosition(
      target: _toGm(initialCenter),
      zoom: 13,
    );

    // Build markers, polylines, and circles for Google Maps
    final markers = <gmaps.Marker>{};
    final polylines = <gmaps.Polyline>{};
    final circles = <gmaps.Circle>{};

    // Add coverage circles around each shelter (2km radius)
    for (int i = 0; i < evacuationRoutes.length; i++) {
      final route = evacuationRoutes[i];
      circles.add(gmaps.Circle(
        circleId: gmaps.CircleId('shelter_coverage_${route.id}'),
        center: _toGm(route.shelterLocation),
        radius: 2000, // 2km coverage area
        fillColor: Colors.red.withOpacity(0.1),
        strokeColor: Colors.red.withOpacity(0.4),
        strokeWidth: 2,
      ));
    }

    // Add routes between shelters (shelter-to-shelter network)
    for (int i = 0; i < evacuationRoutes.length; i++) {
      for (int j = i + 1; j < evacuationRoutes.length; j++) {
        final route1 = evacuationRoutes[i];
        final route2 = evacuationRoutes[j];
        polylines.add(gmaps.Polyline(
          polylineId: gmaps.PolylineId('shelter_connection_${i}_${j}'),
          points: [_toGm(route1.shelterLocation), _toGm(route2.shelterLocation)],
          color: Colors.orange.withOpacity(0.6),
          width: 2,
          geodesic: true,
        ));
      }
    }

    // Add user-to-shelter routes
    for (final route in evacuationRoutes) {
      final shelterGm = _toGm(route.shelterLocation);
      markers.add(gmaps.Marker(
        markerId: gmaps.MarkerId(route.id),
        position: shelterGm,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
        infoWindow: gmaps.InfoWindow(title: route.name),
        onTap: () {
          // If admin, show delete confirmation; otherwise focus camera
          if (widget.isAdmin) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete route?'),
                content: Text('Delete shelter "${route.name}"?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      _deleteRoute(route.id);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          } else {
            _controller.future.then((gm) => gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(shelterGm, 15)));
          }
        },
      ));

      // Polyline points: include userStartPoint if present
      final points = <gmaps.LatLng>[];
      if (userStartPoint != null) points.add(_toGm(userStartPoint!));
      for (final p in route.path) {
        points.add(_toGm(p));
      }
      polylines.add(gmaps.Polyline(
        polylineId: gmaps.PolylineId(route.id),
        points: points,
        color: Colors.blue,
        width: 4,
      ));
    }

    // User marker
    if (userStartPoint != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('__user__'),
        position: _toGm(userStartPoint!),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen),
        infoWindow: const gmaps.InfoWindow(title: 'Your Location'),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Evacuation Routes"),
        backgroundColor: const Color.fromARGB(255, 254, 254, 254),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddRouteDialog,
              backgroundColor: Colors.red,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: gmaps.GoogleMap(
              initialCameraPosition: initialCamera,
              markers: markers,
              polylines: polylines,
              circles: circles,
              onMapCreated: (gm) {
                if (!_controller.isCompleted) _controller.complete(gm);
              },
              myLocationEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),

          // Route list with distances
          if (userStartPoint != null)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[100],
                child: ListView.builder(
                  itemCount: evacuationRoutes.length,
                  itemBuilder: (context, index) {
                    final route = evacuationRoutes[index];
                    final distance =
                        _distanceInKm(userStartPoint!, route.shelterLocation).toStringAsFixed(2);
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(route.name),
                      subtitle: Text("Distance: $distance km"),
                      onTap: () async {
                        final gm = await _controller.future;
                        gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(_toGm(route.shelterLocation), 15));
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
