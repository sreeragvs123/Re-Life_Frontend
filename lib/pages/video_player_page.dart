import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html;
import '../models/video_model.dart';

class VideoPlayerPage extends StatefulWidget {
  final Video video;
  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _errorMessage; // ⭐ stores exact error text so we can see what's wrong

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final video = widget.video;

    // ── Log the URL so you can verify it in debug console ──────────────────
    debugPrint('=== VideoPlayerPage ===');
    debugPrint('Title   : ${video.title}');
    debugPrint('URL     : ${video.url}');
    debugPrint('Path    : ${video.path}');
    debugPrint('Has bytes: ${video.bytes != null}');

    try {
      if (video.url != null) {
        debugPrint('Using networkUrl: ${video.url}');
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(video.url!),
          httpHeaders: {'Connection': 'keep-alive'},
        );
      } else if (kIsWeb && video.bytes != null) {
        final blob = html.Blob([video.bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      } else if (!kIsWeb && video.path != null) {
        _controller = VideoPlayerController.file(File(video.path!));
      } else {
        _setError('No video source available (url, path, bytes are all null)');
        return;
      }

      debugPrint('Calling initialize()...');
      await _controller!.initialize();
      debugPrint('Initialize complete. Duration: ${_controller!.value.duration}');
      debugPrint('Size: ${_controller!.value.size}');
      debugPrint('hasError: ${_controller!.value.hasError}');
      debugPrint('errorDescription: ${_controller!.value.errorDescription}');

      // Check if controller itself reported an error after initialize
      if (_controller!.value.hasError) {
        _setError(_controller!.value.errorDescription ?? 'Unknown player error');
        return;
      }

      // Auto-play so user doesn't need to tap
      await _controller!.play();

      if (mounted) setState(() => _initialized = true);
    } catch (e, st) {
      debugPrint('VideoPlayer EXCEPTION: $e');
      debugPrint('Stack: $st');
      _setError(e.toString());
    }
  }

  void _setError(String msg) {
    debugPrint('VideoPlayer error set: $msg');
    if (mounted) setState(() => _errorMessage = msg);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.video.title,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _errorMessage != null
          // ── Error state — shows EXACT error so we know what to fix ────────
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Could not play video',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // ⭐ Show full error text — screenshot this and share it
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Also show the URL being used
                    if (widget.video.url != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey[900],
                        child: SelectableText(
                          'URL: ${widget.video.url}',
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 11),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        _controller?.dispose();
                        _controller = null;
                        _initialized = false;
                        _initController();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            )
          : !_initialized || _controller == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.deepPurple),
                      SizedBox(height: 16),
                      Text('Loading video...',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller!,
                  builder: (context, value, _) {
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(_controller!),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => value.isPlaying
                                        ? _controller!.pause()
                                        : _controller!.play(),
                                  ),
                                  if (!value.isPlaying)
                                    IgnorePointer(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.deepPurple,
                            bufferedColor: Colors.purple.shade200,
                            backgroundColor: Colors.grey.shade800,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 52,
                                icon: Icon(
                                  value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: Colors.white,
                                ),
                                onPressed: () => value.isPlaying
                                    ? _controller!.pause()
                                    : _controller!.play(),
                              ),
                              const SizedBox(width: 24),
                              IconButton(
                                iconSize: 40,
                                icon: const Icon(Icons.replay,
                                    color: Colors.white70),
                                onPressed: () =>
                                    _controller!.seekTo(Duration.zero),
                              ),
                              const SizedBox(width: 24),
                              Text(
                                _formatDuration(value.position),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                              const Text(' / ',
                                  style: TextStyle(color: Colors.white38)),
                              Text(
                                _formatDuration(value.duration),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}