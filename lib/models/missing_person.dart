class MissingPerson {
  final int? id;
  final String name;
  final int age;
  final String lastSeen;
  final String description;
  final String familyName;
  final String familyContact;
  bool isFound;

  MissingPerson({
    this.id,
    required this.name,
    required this.age,
    required this.lastSeen,
    required this.description,
    required this.familyName,
    required this.familyContact,
    this.isFound = false,
  });

  factory MissingPerson.fromJson(Map<String, dynamic> json) {
    return MissingPerson(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      lastSeen: json['lastSeen'],
      description: json['description'],
      familyName: json['familyName'],
      familyContact: json['familyContact'],
      isFound: json['isFound'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "lastSeen": lastSeen,
      "description": description,
      "familyName": familyName,
      "familyContact": familyContact,
      "isFound": isFound,
    };
  }
}
