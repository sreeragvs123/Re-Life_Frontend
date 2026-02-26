import 'dart:typed_data';

class Video {
  final int? id;             // backend id — null before upload completes
  final String title;
  final String? url;         // backend-served URL — used for network playback
  final String? path;        // local file path (mobile only, pre-upload)
  final Uint8List? thumbnail; // local thumbnail (mobile only)
  final Uint8List? bytes;    // local file bytes (web only, pre-upload)
  String status;             // 'pending' or 'approved'
  final String uploader;

  Video({
    this.id,
    required this.title,
    this.url,
    this.path,
    this.thumbnail,
    this.bytes,
    this.status = 'pending',
    this.uploader = 'unknown',
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'] ?? '',
      url: json['url'],
      status: json['status'] ?? 'pending',
      uploader: json['uploader'] ?? 'unknown',
      // path, thumbnail, bytes are local-only — never come from backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'uploader': uploader,
    };
  }

  // Used as a unique key in widget trees — works for both local and backend videos
  String get key => id?.toString() ?? '$title-$uploader';
}