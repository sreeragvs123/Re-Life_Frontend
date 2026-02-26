import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../api/video_api.dart';
import '../widgets/video_card.dart';
import 'video_player_page.dart';

class AdminVideoApprovalPage extends StatefulWidget {
  const AdminVideoApprovalPage({super.key});

  @override
  State<AdminVideoApprovalPage> createState() => _AdminVideoApprovalPageState();
}

class _AdminVideoApprovalPageState extends State<AdminVideoApprovalPage> {
  List<Video> _videos = [];
  bool _isLoading = true;
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

  Future<void> _approveVideo(Video video) async {
    if (video.id == null) return;
    try {
      final updated = await VideoApi.approveVideo(video.id!);
      setState(() {
        final i = _videos.indexWhere((v) => v.id == video.id);
        if (i != -1) _videos[i] = updated;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green.shade600,
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text("'${video.title}' approved!")),
        ]),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approve failed: $e')));
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Admin Video Approval'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVideos),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Failed to load:\n$_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadVideos, child: const Text('Retry')),
                  ],
                ))
              : _videos.isEmpty
                  ? const Center(child: Text('No videos uploaded yet.',
                      style: TextStyle(color: Colors.white70, fontSize: 16)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 25 / 25,
                      ),
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        final video = _videos[index];
                        // ⭐ FIX: Pass all callbacks directly — no outer GestureDetector
                        return VideoCard(
                          key: ValueKey(video.key),
                          video: video,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerPage(video: video),
                            ),
                          ),
                          onApprove: video.status == 'pending'
                              ? () => _approveVideo(video)
                              : null,
                          onDelete: () => _deleteVideo(video),
                        );
                      },
                    ),
    );
  }
}