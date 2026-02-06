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
}
