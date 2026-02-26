import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:universal_html/html.dart' as html;
import '../../models/video_model.dart';
import '../../api/video_api.dart';
import '../../widgets/video_card.dart';
import 'video_player_page.dart';

class VolunteerVideoPage extends StatefulWidget {
  final String volunteerName;
  const VolunteerVideoPage({super.key, required this.volunteerName});

  @override
  State<VolunteerVideoPage> createState() => _VolunteerVideoPageState();
}

class _VolunteerVideoPageState extends State<VolunteerVideoPage> {
  List<Video> _videos = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final videos = await VideoApi.getAllVideos();
      if (mounted) setState(() => _videos = videos);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> pickVideo() async {
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );
      if (result == null) { setState(() => _isUploading = false); return; }

      final fileName = result.files.single.name;
      Video uploaded;

      if (kIsWeb && result.files.single.bytes != null) {
        uploaded = await VideoApi.uploadVideo(
          title: fileName,
          uploader: widget.volunteerName,
          bytes: result.files.single.bytes,
          fileName: fileName,
        );
      } else if (!kIsWeb && result.files.single.path != null) {
        final thumb = await VideoThumbnail.thumbnailData(
          video: result.files.single.path!,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 150,
          quality: 75,
        );
        uploaded = await VideoApi.uploadVideo(
          title: fileName,
          uploader: widget.volunteerName,
          filePath: result.files.single.path,
          fileName: fileName,
        );
        uploaded = Video(
          id: uploaded.id, title: uploaded.title, url: uploaded.url,
          status: uploaded.status, uploader: uploaded.uploader, thumbnail: thumb,
        );
      } else {
        throw Exception('Unable to get video data.');
      }

      setState(() => _videos.add(uploaded));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green.shade600,
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text("'$fileName' uploaded! Pending admin approval.")),
        ]),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Row(children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text('Upload failed: $e')),
        ]),
      ));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteVideo(Video video) async {
    if (video.id == null) return;
    try {
      await VideoApi.deleteVideo(video.id!);
      setState(() => _videos.removeWhere((v) => v.id == video.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade600,
        content: const Row(children: [
          Icon(Icons.delete, color: Colors.white),
          SizedBox(width: 8), Text('Video deleted.'),
        ]),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVideos),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _isUploading ? null : pickVideo,
              icon: const Icon(Icons.upload_file),
              label: Text(_isUploading ? 'Uploading...' : 'Pick & Upload Video'),
            ),
          ),
          if (_isUploading)
            const LinearProgressIndicator(minHeight: 5, color: Colors.deepPurple),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text('Failed to load:\n$_error', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _loadVideos, child: const Text('Retry')),
                        ],
                      ))
                    : _videos.isEmpty
                        ? const Center(child: Text('No videos available.',
                            style: TextStyle(fontSize: 16, color: Colors.grey)))
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 16 / 9,
                            ),
                            itemCount: _videos.length,
                            itemBuilder: (context, index) {
                              final video = _videos[index];
                              // ⭐ FIX: Pass onTap directly into VideoCard instead of
                              // wrapping with another GestureDetector. Nested
                              // GestureDetectors on Android give priority to the inner
                              // one — which was calling onTap: () {} (empty), so
                              // VideoPlayerPage was never opened.
                              return VideoCard(
                                key: ValueKey(video.key),
                                video: video,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerPage(video: video),
                                  ),
                                ),
                                onDelete: () => _deleteVideo(video),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}