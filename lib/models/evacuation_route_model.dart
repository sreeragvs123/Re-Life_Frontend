import 'package:latlong2/latlong.dart' as ll;
import 'shelter_model.dart';

// Represents a single lat/lng waypoint along the route path
class Waypoint {
  final double latitude;
  final double longitude;

  Waypoint({required this.latitude, required this.longitude});

  ll.LatLng get latLng => ll.LatLng(latitude, longitude);

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class EvacuationRoute {
  final int? id;
  final String name;
  final int shelterId;

  // Flattened from Shelter for convenience
  final String shelterName;
  final ll.LatLng shelterLocation;

  // Optional admin-defined intermediate waypoints (not counting shelter endpoint)
  final List<Waypoint> waypoints;

  EvacuationRoute({
    this.id,
    required this.name,
    required this.shelterId,
    required this.shelterName,
    required this.shelterLocation,
    this.waypoints = const [],
  });

  // Full path for drawing the polyline — waypoints + shelter as the final point
  List<ll.LatLng> get path => [
        ...waypoints.map((w) => w.latLng),
        shelterLocation,
      ];

  factory EvacuationRoute.fromJson(Map<String, dynamic> json) {
    final shelter = Shelter.fromJson(json['shelter'] as Map<String, dynamic>);

    final waypointsRaw = json['waypoints'] as List<dynamic>? ?? [];
    final waypoints =
        waypointsRaw.map((w) => Waypoint.fromJson(w as Map<String, dynamic>)).toList();

    return EvacuationRoute(
      id: json['id'],
      name: json['name'] ?? '',
      shelterId: shelter.id ?? 0,
      shelterName: shelter.name,
      shelterLocation: shelter.latLng,
      waypoints: waypoints,
    );
  }

  // Used when creating a new route via the admin form
  Map<String, dynamic> toJson() => {
        'name': name,
        'shelterId': shelterId,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
      };
}