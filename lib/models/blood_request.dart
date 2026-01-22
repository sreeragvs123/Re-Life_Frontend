class BloodRequest {
  final int? id;
  final String name;
  final String bloodGroup;
  final String contact;
  final String city;

  BloodRequest({
    this.id,
    required this.name,
    required this.bloodGroup,
    required this.contact,
    required this.city,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['id'],
      name: json['name'],
      bloodGroup: json['bloodGroup'],
      contact: json['contact'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "bloodGroup": bloodGroup,
      "contact": contact,
      "city": city,
    };
  }
}
