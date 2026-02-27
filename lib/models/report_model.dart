class Report {
  final int? id;
  final String volunteerName;
  final String group;
  final String task;
  final String description;
  final DateTime date;

  Report({
    this.id,
    required this.volunteerName,
    required this.group,
    required this.task,
    required this.description,
    required this.date,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      volunteerName: json['volunteerName'] ?? '',
      group: json['group'] ?? '',
      task: json['task'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'volunteerName': volunteerName,
      'group': group,
      'task': task,
      'description': description,
    };
  }
}