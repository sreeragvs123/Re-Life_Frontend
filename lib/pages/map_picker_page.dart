import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerPage extends StatefulWidget {
  final ll.LatLng? initial;
  const MapPickerPage({super.key, this.initial});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  gmaps.LatLng? _picked;
  final TextEditingController _searchController = TextEditingController();

  ll.LatLng _gmToLl(gmaps.LatLng p) => ll.LatLng(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _picked = gmaps.LatLng(widget.initial!.latitude, widget.initial!.longitude);
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location or coordinates')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Searching for location...')),
      );

      gmaps.LatLng pos;
      String displayText;

      // Check if input is coordinates (e.g., "8.4850, 76.2722" or "8.4850,76.2722")
      final coordRegex = RegExp(r'^(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)$');
      final match = coordRegex.firstMatch(query);

      if (match != null) {
        // Parse as coordinates
        try {
          final lat = double.parse(match.group(1)!);
          final lng = double.parse(match.group(2)!);

          // Validate coordinates
          if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid coordinates. Latitude: -90 to 90, Longitude: -180 to 180')),
            );
            return;
          }

          pos = gmaps.LatLng(lat, lng);

          // Reverse geocode to get location name
          final placemarks = await placemarkFromCoordinates(lat, lng);
          String placeName = query;
          if (placemarks.isNotEmpty) {
            final pm = placemarks.first;
            placeName = '${pm.name ?? pm.street ?? ''}, ${pm.locality ?? pm.administrativeArea ?? ''}'.replaceAll(RegExp(r',\s*$'), '');
            if (placeName.trim().isEmpty) placeName = query;
          }
          displayText = 'Found: $placeName';
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid coordinates format. Use: latitude, longitude')),
          );
          return;
        }
      } else {
        // Search by location name
        final locations = await locationFromAddress(query);

        if (locations.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found. Try a different name or use coordinates (lat, lng).')),
          );
          return;
        }

        final location = locations.first;
        pos = gmaps.LatLng(location.latitude, location.longitude);
        displayText = 'Found: $query (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
      }

      // Move map to the found location
      final ctrl = await _controller.future;
      ctrl.animateCamera(gmaps.CameraUpdate.newLatLng(pos));

      setState(() {
        _picked = pos;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayText),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: $e')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _picked = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search cleared. Enter a location name or tap map.')),
    );
  }

  Future<void> _moveToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    final pos = gmaps.LatLng(position.latitude, position.longitude);
    final ctrl = await _controller.future;
    ctrl.animateCamera(gmaps.CameraUpdate.newLatLng(pos));
    setState(() {
      _picked = pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final start = _picked ?? const gmaps.LatLng(8.8932, 76.6141);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 9.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
              onPressed: () {
                if (_picked == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tap the map to select a location')),
                  );
                  return;
                }
                final ll.LatLng result = _gmToLl(_picked!);
                Navigator.of(context).pop(result);
              },
              child: const Text(
                'USE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(target: start, zoom: 13),
            onMapCreated: (c) {
              if (!_controller.isCompleted) _controller.complete(c);
            },
            onTap: (pos) => setState(() => _picked = pos),
            markers: _picked == null
                ? <gmaps.Marker>{}
                : {
                    gmaps.Marker(
                      markerId: const gmaps.MarkerId('picked'),
                      position: _picked!,
                    )
                  },
            zoomControlsEnabled: true,
            myLocationEnabled: false,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _searchLocation(),
                    decoration: InputDecoration(
                      hintText: 'Search location (e.g. "Kochi", "Mall Road")',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchLocation,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.blue, size: 32),
                  onPressed: _moveToCurrentLocation,
                  tooltip: 'Go to my location',
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red, size: 32),
                  onPressed: () => setState(() => _picked = null),
                  tooltip: 'Clear marker',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}