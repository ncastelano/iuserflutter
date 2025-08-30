import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProfile extends StatefulWidget {
  final List<Map<String, dynamic>> videoList;
  final int startIndex;

  const VideoPlayerProfile({
    Key? key,
    required this.videoList,
    required this.startIndex,
  }) : super(key: key);

  @override
  State<VideoPlayerProfile> createState() => _VideoPlayerProfileState();
}

class _VideoPlayerProfileState extends State<VideoPlayerProfile> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.videoList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final videoData = widget.videoList[index];
          return Stack(
            children: [
              _VideoPlayer(videoUrl: videoData["videoUrl"]),
              Positioned(
                bottom: 80,
                left: 20,
                right: 20,
                child: _VideoInfoOverlay(videoData: videoData),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: BackButton(color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
          : const CircularProgressIndicator(),
    );
  }
}

class _VideoInfoOverlay extends StatelessWidget {
  final Map<String, dynamic> videoData;

  const _VideoInfoOverlay({Key? key, required this.videoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            videoData["artistSongName"] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            videoData["descriptionTags"] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(videoData["userProfileImage"] ?? ''),
              ),
              const SizedBox(width: 8),
              Text(
                videoData["userName"] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
