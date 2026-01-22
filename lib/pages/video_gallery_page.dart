import 'package:flutter/material.dart';
import '../data/video_data.dart';
import '../widgets/video_card.dart';
import 'volunteer_video_page.dart'; // VideoPlayerPage

class VideoGalleryPage extends StatelessWidget {
  const VideoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Only approved videos
    final approvedVideos = videos.where((v) => v.status == 'approved').toList();// this collection those vedios in the list that are been approved by the admin

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Video Gallery",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: approvedVideos.isEmpty
            ? const Center(
                child: Text(
                  "No videos available yet.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 per row
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 25 / 25, // keeps VideoCard ratio
                ),
                itemCount: approvedVideos.length,
                itemBuilder: (context, index) {
                  final video = approvedVideos[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(video: video),
                        ),
                      );
                    },
                    child: VideoCard(video: video, onTap: () {}),
                  );
                },
              ),
      ),
    );
  }
}