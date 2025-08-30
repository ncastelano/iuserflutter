import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPreview extends StatelessWidget {
  final VideoPlayerController controller;

  VideoPlayerPreview(this.controller);

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    )
        : const Center(child: CircularProgressIndicator());
  }
}