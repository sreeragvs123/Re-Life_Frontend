import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/shelter_model.dart';
import '../api/map_api.dart';              // ⭐ Use API instead of local data
import 'add_shelter_route_page.dart';
import 'shelter_detail_page.dart';
import 'user_shelter_map_page.dart';
import 'map_picker_page.dart';

class ShelterListPage extends StatefulWidget {
  final bool isAdmin;
  const ShelterListPage({super.key, this.isAdmin = false});

  @override
  State<ShelterListPage> createState() => _ShelterListPageState();
}

class _ShelterListPageState extends State<ShelterListPage> {
  // ── State ─────────────────────────────────────────────────────────────────
  List<Shelter> _shelters = [];
  bool _isLoading = true;
  String? _error;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadShelters();
  }

  // ── API ───────────────────────────────────────────────────────────────────
  Future<void> _loadShelters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final shelters = await MapApi.getAllShelters();
      if (mounted) setState(() => _shelters = shelters);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteShelter(Shelter shelter) async {
    try {
      await MapApi.deleteShelter(shelter.id!);
      await _loadShelters();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shelter "${shelter.name}" deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Navigation helpers ────────────────────────────────────────────────────
  void _goToAddShelter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddShelterRoutePage()),
    );
    if (result == true) _loadShelters(); // Refresh from API after adding
  }

  void _pickUserLocationForMap() async {
    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserShelterMapPage(
            userLocation: result,
            shelters: _shelters,    // ⭐ Pass API-loaded shelters down
          ),
        ),
      );
    }
  }

  void _confirmDelete(Shelter shelter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shelter?'),
        content: Text('Permanently delete "${shelter.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteShelter(shelter);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shelters"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadShelters,
            tooltip: 'Refresh',
          ),
          Tooltip(
            message: "View all shelters on map",
            child: IconButton(
              icon: const Icon(Icons.map),
              onPressed: _isLoading || _shelters.isEmpty
                  ? null
                  : _pickUserLocationForMap,
            ),
          ),
        ],
      ),
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
                      Text('Failed to load shelters:\n$_error',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadShelters,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : _shelters.isEmpty
                  ? const Center(child: Text("No shelters available"))
                  : ListView.builder(
                      itemCount: _shelters.length,
                      itemBuilder: (_, index) {
                        final shelter = _shelters[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.home,
                                color: Colors.blueGrey, size: 32),
                            title: Text(
                              shelter.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              shelter.address != null
                                  ? shelter.address!
                                  : '${shelter.latitude.toStringAsFixed(4)}, '
                                      '${shelter.longitude.toStringAsFixed(4)}',
                            ),
                            trailing: widget.isAdmin
                                ? IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _confirmDelete(shelter),
                                  )
                                : const Icon(Icons.location_on,
                                    color: Colors.red),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ShelterDetailPage(shelter: shelter),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _goToAddShelter,
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}