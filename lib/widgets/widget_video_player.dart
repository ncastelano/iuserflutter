import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WidgetVideoPlayer extends StatefulWidget {
  final String videoFileUrl;
  final double extraBottomSpace; // <-- Novo parâmetro opcional

  const WidgetVideoPlayer({
    required this.videoFileUrl,
    required this.extraBottomSpace, // valor padrão
    Key? key,
  }) : super(key: key);

  @override
  State<WidgetVideoPlayer> createState() => _WidgetVideoPlayerState();
}

class _WidgetVideoPlayerState extends State<WidgetVideoPlayer> {
  VideoPlayerController? playerController;

  @override
  void initState() {
    super.initState();

    playerController = VideoPlayerController.network(widget.videoFileUrl)
      ..initialize().then((_) {
        setState(() {}); // Atualiza o estado após inicializar
        playerController!.play();
        playerController!.setLooping(false);
        playerController!.setVolume(1.0);
      });
  }

  @override
  void dispose() {
    playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = MediaQuery.of(context).size.height - widget.extraBottomSpace;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: totalHeight,
      child: playerController != null && playerController!.value.isInitialized
          ? FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: playerController!.value.size.width,
          height: playerController!.value.size.height,
          child: VideoPlayer(playerController!),
        ),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
