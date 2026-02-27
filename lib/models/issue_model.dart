// lib/models/issue_model.dart
import 'dart:typed_data';
import 'dart:convert';

class Issue {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String title;
  final String description;
  final String? category;
  final String? priority;
  final String? location;
  final Uint8List? attachment;      // local bytes for display
  final String? attachmentBase64;   // base64 string stored in backend
  final DateTime date;

  Issue({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.title,
    required this.description,
    this.category,
    this.priority,
    this.location,
    this.attachment,
    this.attachmentBase64,
    required this.date,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    Uint8List? attachmentBytes;
    final b64 = json['attachmentBase64'] as String?;
    if (b64 != null && b64.isNotEmpty) {
      try {
        attachmentBytes = base64Decode(b64);
      } catch (_) {}
    }
    return Issue(
      id:               json['id'],
      name:             json['name']        ?? '',
      email:            json['email']       ?? '',
      phone:            json['phone'],
      title:            json['title']       ?? '',
      description:      json['description'] ?? '',
      category:         json['category'],
      priority:         json['priority'],
      location:         json['location'],
      attachment:       attachmentBytes,
      attachmentBase64: b64,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    String? b64;
    if (attachment != null) {
      b64 = base64Encode(attachment!);
    }
    return {
      'name':             name,
      'email':            email,
      'phone':            phone,
      'title':            title,
      'description':      description,
      'category':         category,
      'priority':         priority,
      'location':         location,
      'attachmentBase64': b64,
    };
  }
}