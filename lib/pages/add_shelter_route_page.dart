// lib/pages/add_shelter_route_page.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'map_picker_page.dart';
import '../models/shelter_model.dart';
import '../models/evacuation_route_model.dart';
import '../api/map_api.dart';            // ⭐ Use API instead of local data

class AddShelterRoutePage extends StatefulWidget {
  const AddShelterRoutePage({super.key});

  @override
  State<AddShelterRoutePage> createState() => _AddShelterRoutePageState();
}

class _AddShelterRoutePageState extends State<AddShelterRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _filledController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();

  ll.LatLng? shelterLatLng;
  bool _isSaving = false;   // ⭐ Tracks API call in progress to prevent double-tap

  // ── Reverse geocode (unchanged from original) ──────────────────────────────
  Future<String?> _reverseGeocode(double lat, double lng) async {
    const String apiKey = String.fromEnvironment(
        'AIzaSyDk5-TmduiN-vjC2i2POHwJqmTePuufVnY',
        defaultValue: '');
    if (apiKey.isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'key': apiKey,
    });
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        final results = json['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          return results.first['formatted_address'] as String?;
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Save — now calls the backend ───────────────────────────────────────────
  Future<void> _saveShelter() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // Validate map pick
    if (shelterLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the shelter location on the map")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // ── Step 1: Create Shelter via API ──────────────────────────────────────
      final createdShelter = await MapApi.createShelter(
        Shelter(
          name: _nameController.text.trim(),
          latitude: shelterLatLng!.latitude,
          longitude: shelterLatLng!.longitude,
          address: _locationController.text.trim(),
          capacity: int.tryParse(_capacityController.text.trim()),
        ),
      );

      // ── Step 2: Create EvacuationRoute linked to that Shelter ───────────────
      // The default start waypoint is the district HQ (same as original fallback)
      const ll.LatLng defaultStart = ll.LatLng(8.8932, 76.6141);

      await MapApi.createEvacuationRoute(
        EvacuationRoute(
          name: createdShelter.name,
          shelterId: createdShelter.id!,
          shelterName: createdShelter.name,
          shelterLocation: createdShelter.latLng,
          waypoints: [
            Waypoint(
              latitude: defaultStart.latitude,
              longitude: defaultStart.longitude,
            ),
          ],
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shelter "${createdShelter.name}" saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Return true so callers (e.g. AdminHome) can refresh their list
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save shelter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _filledController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Shelter & Route")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: "Shelter Name"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter shelter name" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Capacity"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter capacity" : null,
                  ),
                  const SizedBox(height: 8),

                  // ⭐ NOTE: "filled" is a UI-only field (not stored in the
                  // backend Shelter entity yet). Keep it here for display
                  // purposes; add a `filledCount` column to Shelter entity
                  // and ShelterDTO if you want to persist it.
                  TextFormField(
                    controller: _filledController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Currently Filled"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter filled count" : null,
                  ),
                  const SizedBox(height: 8),

                  // ⭐ NOTE: "contact" is also UI-only for now. Add a
                  // `contact` column to Shelter + ShelterDTO to persist it.
                  TextFormField(
                    controller: _contactController,
                    decoration:
                        const InputDecoration(labelText: "Contact"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter contact" : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration:
                        const InputDecoration(labelText: "Address"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter address" : null,
                  ),
                  const SizedBox(height: 10),

                  // ── Map picker button ──────────────────────────────────────
                  ElevatedButton.icon(
                    icon: const Icon(Icons.location_on),
                    label: Text(shelterLatLng == null
                        ? "Pick Shelter Location on Map"
                        : "Location: ${shelterLatLng!.latitude.toStringAsFixed(4)}, "
                            "${shelterLatLng!.longitude.toStringAsFixed(4)}"),
                    onPressed: () async {
                      final result = await Navigator.of(context)
                          .push<ll.LatLng?>(MaterialPageRoute(
                        builder: (_) =>
                            MapPickerPage(initial: shelterLatLng),
                      ));
                      if (result != null) {
                        setState(() => shelterLatLng = result);
                        final addr = await _reverseGeocode(
                            result.latitude, result.longitude);
                        if (!mounted) return;
                        _locationController.text = (addr != null && addr.isNotEmpty)
                            ? addr
                            : '${result.latitude.toStringAsFixed(6)}, '
                                '${result.longitude.toStringAsFixed(6)}';
                      }
                    },
                  ),

                  // Visual confirmation chip when location is picked
                  if (shelterLatLng != null) ...[
                    const SizedBox(height: 6),
                    Chip(
                      avatar: const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      label: const Text("Location selected"),
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Save button — shows spinner while saving ───────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveShelter,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save Shelter",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}