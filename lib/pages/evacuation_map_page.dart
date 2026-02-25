// lib/pages/evacuation_map_page.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../../models/shelter_model.dart';
import '../../models/evacuation_route_model.dart';
import '../../api/map_api.dart';
import 'map_picker_page.dart';

class EvacuationMapPage extends StatefulWidget {
  final bool isAdmin;
  const EvacuationMapPage({super.key, this.isAdmin = false});

  @override
  State<EvacuationMapPage> createState() => _EvacuationMapPageState();
}

class _EvacuationMapPageState extends State<EvacuationMapPage> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();

  // ── State ────────────────────────────────────────────────────────────────
  List<EvacuationRoute> _routes = [];
  bool _isLoading = true;
  String? _error;

  ll.LatLng? userStartPoint;
  final TextEditingController _nameController = TextEditingController();

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadRoutes();
    if (!widget.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askUserLocation());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── API Calls ────────────────────────────────────────────────────────────

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final routes = await MapApi.getAllEvacuationRoutes();
      if (mounted) setState(() => _routes = routes);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addRouteToBackend(String name, ll.LatLng shelterLocation) async {
    try {
      // Step 1 — create the Shelter
      final newShelter = await MapApi.createShelter(
        Shelter(
          name: name,
          latitude: shelterLocation.latitude,
          longitude: shelterLocation.longitude,
        ),
      );

      // Step 2 — create the EvacuationRoute linked to that shelter
      final fallback = ll.LatLng(8.8932, 76.6141);
      final startPoint = userStartPoint ?? fallback;

      await MapApi.createEvacuationRoute(
        EvacuationRoute(
          name: name,
          shelterId: newShelter.id!,
          shelterName: newShelter.name,
          shelterLocation: newShelter.latLng,
          waypoints: [
            Waypoint(
              latitude: startPoint.latitude,
              longitude: startPoint.longitude,
            ),
          ],
        ),
      );

      await _loadRoutes(); // Refresh from backend

      if (mounted) {
        final gm = await _controller.future;
        gm.animateCamera(
          gmaps.CameraUpdate.newLatLng(_toGm(shelterLocation)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shelter "$name" added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add shelter: $e')),
        );
      }
    }
  }

  Future<void> _deleteRoute(EvacuationRoute route) async {
    try {
      await MapApi.deleteEvacuationRoute(route.id!);
      // Also delete the shelter since it was created together
      await MapApi.deleteShelter(route.shelterId);
      await _loadRoutes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shelter "${route.shelterName}" deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  // ── UI Helpers ───────────────────────────────────────────────────────────

  gmaps.LatLng _toGm(ll.LatLng p) => gmaps.LatLng(p.latitude, p.longitude);

  void _askUserLocation() async {
    if (!mounted) return;
    final picked = await Navigator.of(context).push<ll.LatLng>(
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (picked != null && mounted) {
      setState(() => userStartPoint = picked);
    }
  }

  double _distanceInKm(ll.LatLng a, ll.LatLng b) {
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

  // ── Admin: Add Route Dialog ───────────────────────────────────────────────

  void _showAddRouteDialog() async {
    _nameController.clear();

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
                  decoration: const InputDecoration(labelText: "Shelter Name"),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final enteredName = _nameController.text.trim();
                    if (enteredName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please enter a shelter name first")),
                      );
                      return;
                    }
                    Navigator.of(context).pop(); // close dialog before map

                    final picked = await Navigator.of(context).push<ll.LatLng>(
                      MaterialPageRoute(
                          builder: (_) => const MapPickerPage()),
                    );
                    if (picked != null && mounted) {
                      await _addRouteToBackend(enteredName, picked);
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

  // ── Admin: Delete Confirmation ────────────────────────────────────────────

  void _confirmDelete(EvacuationRoute route) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shelter?'),
        content: Text(
            'This will permanently delete shelter "${route.shelterName}" and its route.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteRoute(route);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final fallback = ll.LatLng(8.8932, 76.6141);
    final initialCenter = userStartPoint ??
        (_routes.isNotEmpty ? _routes.first.shelterLocation : fallback);

    final initialCamera = gmaps.CameraPosition(
      target: _toGm(initialCenter),
      zoom: 13,
    );

    // Build map overlays
    final markers = <gmaps.Marker>{};
    final polylines = <gmaps.Polyline>{};
    final circles = <gmaps.Circle>{};

    for (int i = 0; i < _routes.length; i++) {
      final route = _routes[i];
      final shelterGm = _toGm(route.shelterLocation);

      // Coverage circle (2 km) around each shelter
      circles.add(gmaps.Circle(
        circleId: gmaps.CircleId('coverage_${route.id}'),
        center: shelterGm,
        radius: 2000,
        fillColor: Colors.red.withOpacity(0.1),
        strokeColor: Colors.red.withOpacity(0.4),
        strokeWidth: 2,
      ));

      // Shelter-to-shelter connection lines
      for (int j = i + 1; j < _routes.length; j++) {
        polylines.add(gmaps.Polyline(
          polylineId: gmaps.PolylineId('s2s_${i}_$j'),
          points: [shelterGm, _toGm(_routes[j].shelterLocation)],
          color: Colors.orange.withOpacity(0.6),
          width: 2,
          geodesic: true,
        ));
      }

      // Shelter marker
      markers.add(gmaps.Marker(
        markerId: gmaps.MarkerId('shelter_${route.id}'),
        position: shelterGm,
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueRed),
        infoWindow: gmaps.InfoWindow(title: route.shelterName),
        onTap: () {
          if (widget.isAdmin) {
            _confirmDelete(route);
          } else {
            _controller.future.then((gm) =>
                gm.animateCamera(gmaps.CameraUpdate.newLatLngZoom(shelterGm, 15)));
          }
        },
      ));

      // User → shelter polyline
      final points = <gmaps.LatLng>[];
      if (userStartPoint != null) points.add(_toGm(userStartPoint!));
      for (final wp in route.waypoints) {
        points.add(_toGm(wp.latLng));
      }
      points.add(shelterGm);
      polylines.add(gmaps.Polyline(
        polylineId: gmaps.PolylineId('route_${route.id}'),
        points: points,
        color: Colors.blue,
        width: 4,
      ));
    }

    // User location marker
    if (userStartPoint != null) {
      markers.add(gmaps.Marker(
        markerId: const gmaps.MarkerId('__user__'),
        position: _toGm(userStartPoint!),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueGreen),
        infoWindow: const gmaps.InfoWindow(title: 'Your Location'),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Evacuation Routes"),
        backgroundColor: const Color.fromARGB(255, 254, 254, 254),
        actions: [
          // Reload button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
            tooltip: 'Refresh routes',
          ),
          // User: re-pick location
          if (!widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _askUserLocation,
              tooltip: 'Change my location',
            ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddRouteDialog,
              backgroundColor: Colors.red,
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Failed to load routes:\n$_error',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadRoutes,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
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

                    // Route list with distances (user mode)
                    if (userStartPoint != null && _routes.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.grey[100],
                          child: ListView.builder(
                            itemCount: _routes.length,
                            itemBuilder: (context, index) {
                              final route = _routes[index];
                              final distance = _distanceInKm(
                                      userStartPoint!, route.shelterLocation)
                                  .toStringAsFixed(2);
                              return ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.red),
                                title: Text(route.shelterName),
                                subtitle: Text("Distance: $distance km"),
                                onTap: () async {
                                  final gm = await _controller.future;
                                  gm.animateCamera(
                                      gmaps.CameraUpdate.newLatLngZoom(
                                          _toGm(route.shelterLocation), 15));
                                },
                              );
                            },
                          ),
                        ),
                      ),

                    // Admin mode: shelter list
                    if (widget.isAdmin && _routes.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.grey[100],
                          child: ListView.builder(
                            itemCount: _routes.length,
                            itemBuilder: (context, index) {
                              final route = _routes[index];
                              return ListTile(
                                leading: const Icon(Icons.home,
                                    color: Colors.red),
                                title: Text(route.shelterName),
                                subtitle: Text(
                                    '${route.shelterLocation.latitude.toStringAsFixed(4)}, '
                                    '${route.shelterLocation.longitude.toStringAsFixed(4)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _confirmDelete(route),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    if (_routes.isEmpty && !_isLoading)
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'No evacuation routes yet.\nAdmin can add shelters using the + button.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}