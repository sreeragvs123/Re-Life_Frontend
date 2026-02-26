import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/video_model.dart';

class VideoCard extends StatefulWidget {
  final Video video;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.onDelete,
    this.onApprove,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  Uint8List? _thumbnail;
  bool _thumbLoading = false;

  @override
  void initState() {
    super.initState();
    // If the video already has a local thumbnail (post-upload preview), use it.
    // Otherwise generate one from the backend URL.
    if (widget.video.thumbnail != null) {
      _thumbnail = widget.video.thumbnail;
    } else if (widget.video.url != null) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    if (_thumbLoading) return;
    setState(() => _thumbLoading = true);
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.video.url!,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 70,
      );
      if (mounted) setState(() => _thumbnail = bytes);
    } catch (e) {
      // Thumbnail generation failed — grey placeholder will show instead
      debugPrint('Thumbnail error for ${widget.video.title}: $e');
    } finally {
      if (mounted) setState(() => _thumbLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        key: ValueKey(widget.video.key),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Thumbnail ───────────────────────────────────────────────
              _thumbnail != null
                  ? Image.memory(_thumbnail!, fit: BoxFit.cover)
                  : _thumbLoading
                      ? Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white38),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.video_file,
                                size: 48, color: Colors.white38),
                          ),
                        ),

              // Play icon overlay
              const Center(
                child: Icon(Icons.play_circle_outline,
                    size: 52, color: Colors.white70),
              ),

              // Pending badge
              if (widget.video.status == 'pending')
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Pending',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),

              // Title bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 4),
                  color: Colors.black54,
                  child: Text(
                    widget.video.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Approve button
              if (widget.video.status == 'pending' &&
                  widget.onApprove != null)
                Positioned(
                  bottom: 30,
                  right: 6,
                  child: ElevatedButton.icon(
                    onPressed: widget.onApprove,
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Approve',
                        style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),

              // Delete button
              if (widget.onDelete != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: ElevatedButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete, size: 14),
                    label: const Text('Delete',
                        style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(70, 28),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}