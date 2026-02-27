// lib/models/product_request.dart

class ProductRequest {
  final int? id;
  final String name;
  final int quantity;
  final String requester; // Admin or Volunteer name
  final String urgency;   // "High", "Medium", "Low"

  const ProductRequest({
    this.id,
    required this.name,
    required this.quantity,
    required this.requester,
    required this.urgency,
  });

  factory ProductRequest.fromJson(Map<String, dynamic> json) {
    return ProductRequest(
      id: json['id'] as int?,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      requester: json['requester'] as String,
      urgency: json['urgency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'requester': requester,
      'urgency': urgency,
    };
  }
}