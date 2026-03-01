// lib/models/group_task.dart

class GroupTask {
  final int? id;
  final String place;
  final String task;
  final DateTime? createdAt;

  const GroupTask({
    this.id,
    required this.place,
    required this.task,
    this.createdAt,
  });

  factory GroupTask.fromJson(Map<String, dynamic> json) {
    return GroupTask(
      // FIX: Java Long arrives as int, double, or String — handle all three
      id:    _parseInt(json['id']),
      place: json['place'] as String,
      task:  json['task']  as String,
      // FIX: Spring's LocalDateTime serialises as array [2024,1,15,10,30,0]
      // or ISO string "2024-01-15T10:30:00" depending on Jackson config.
      // _parseDateTime handles both formats safely.
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Jackson's LocalDateTime default serialisation is a JSON array:
  // [2024, 1, 15, 10, 30, 0, 0]  → [year, month, day, hour, min, sec, nano]
  // If you add @JsonFormat(shape=STRING) or use JavaTimeModule it becomes a string.
  // This helper handles BOTH so the app works regardless of backend Jackson config.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    // Already a String (ISO format)
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    // Array format: [year, month, day, hour, minute, second, nanosecond?]
    if (value is List && value.length >= 3) {
      try {
        final year   = (value[0] as num).toInt();
        final month  = (value[1] as num).toInt();
        final day    = (value[2] as num).toInt();
        final hour   = value.length > 3 ? (value[3] as num).toInt() : 0;
        final minute = value.length > 4 ? (value[4] as num).toInt() : 0;
        final second = value.length > 5 ? (value[5] as num).toInt() : 0;
        return DateTime(year, month, day, hour, minute, second);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'place': place,
      'task':  task,
    };
  }
}