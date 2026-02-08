class Donation {
  final int? id;
  final String donorName;
  final String contact;
  final String address;
  final String item;
  final int quantity;
  final DateTime date;
  bool isApproved;
  String status;

  Donation({
    this.id,
    required this.donorName,
    required this.contact,
    required this.address,
    required this.item,
    required this.quantity,
    required this.date,
    this.isApproved = false,
    this.status = "Pending",
  });

  // From JSON
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      donorName: json['donorName'] ?? '',
      contact: json['contact'] ?? '',
      address: json['address'] ?? '',
      item: json['item'] ?? '',
      quantity: json['quantity'] ?? 0,
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      isApproved: json['isApproved'] ?? false,
      status: json['status'] ?? 'Pending',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'donorName': donorName,
      'contact': contact,
      'address': address,
      'item': item,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'isApproved': isApproved,
      'status': status,
    };
  }
}