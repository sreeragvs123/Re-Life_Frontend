// lib/models/product_request.dart

class ProductRequest {
  final int? id;
  final String name;
  final int quantity;
  final String requester;
  final String urgency; // "High" | "Medium" | "Low"

  const ProductRequest({
    this.id,
    required this.name,
    required this.quantity,
    required this.requester,
    required this.urgency,
  });

  factory ProductRequest.fromJson(Map<String, dynamic> json) {
    return ProductRequest(
      // FIX: Java Long can come back as int, double, or String depending on
      // the platform and Jackson config. _parseInt handles all three safely.
      id:        _parseInt(json['id']),
      name:      json['name']      as String,
      quantity:  _parseInt(json['quantity']) ?? 0,
      requester: json['requester'] as String,
      urgency:   json['urgency']   as String,
    );
  }

  // Safely converts int, double, or String → int (returns null if input is null)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name':      name,
      'quantity':  quantity,
      'requester': requester,
      'urgency':   urgency,
    };
  }
}