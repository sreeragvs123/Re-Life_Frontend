class Payment {
  final int? id;
  final String razorpayPaymentId;
  final double amount;
  final String contact;
  final String email;
  final String status;
  final DateTime? createdAt;

  Payment({
    this.id,
    required this.razorpayPaymentId,
    required this.amount,
    required this.contact,
    required this.email,
    this.status = 'SUCCESS',
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      razorpayPaymentId: json['razorpayPaymentId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'SUCCESS',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpayPaymentId': razorpayPaymentId,
      'amount': amount,
      'contact': contact,
      'email': email,
      'status': status,
    };
  }
}