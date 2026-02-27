// lib/models/group_task.dart

class GroupTask {
  final int? id;
  final String place;       // group identifier (volunteer's location)
  final String task;        // task description
  final DateTime? createdAt;

  const GroupTask({
    this.id,
    required this.place,
    required this.task,
    this.createdAt,
  });

  factory GroupTask.fromJson(Map<String, dynamic> json) {
    return GroupTask(
      id:    json['id'] as int?,
      place: json['place'] as String,
      task:  json['task']  as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place': place,
      'task':  task,
    };
  }
}