import 'package:latlong2/latlong.dart' as ll;

class Shelter {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final int? capacity;

  Shelter({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.capacity,
  });

  ll.LatLng get latLng => ll.LatLng(latitude, longitude);

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id'],
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      capacity: json['capacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
      if (capacity != null) 'capacity': capacity,
    };
  }
}