class MissingPerson {
  final String id;
  final String name;
  final int age;
  final String lastSeen;
  final String description;
  final String familyName;
  final String familyContact;
  bool isFound;

  MissingPerson({
    required this.id,
    required this.name,
    required this.age,
    required this.lastSeen,
    required this.description,
    required this.familyName,
    required this.familyContact,
    this.isFound = false,
  });

  // ✅ EDITED: Added isFound to fromJson
  factory MissingPerson.fromJson(Map<String, dynamic> json) {
    return MissingPerson(
      id: json['id'].toString(), // Convert to string for consistency
      name: json['name'],
      age: json['age'],
      lastSeen: json['lastSeen'],
      description: json['description'],
      familyName: json['familyName'],
      familyContact: json['familyContact'],
      isFound: json['isFound'] ?? false, // ⭐ ADDED: Handle isFound from backend
    );
  }

  // ✅ EDITED: Added isFound to toJson
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      'age': age,
      "lastSeen": lastSeen,
      "description": description,
      "familyName": familyName,
      "familyContact": familyContact,
      "isFound": isFound, // ⭐ ADDED: Send isFound to backend
    };
  }
}