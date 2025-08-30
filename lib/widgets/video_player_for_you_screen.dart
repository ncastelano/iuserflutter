import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../home/custom_video_player_controller.dart';
import '../home/mute_controller.dart';

class VideoPlayerForYouScreen extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final void Function(CustomVideoPlayerController)? onControllerReady;

  const VideoPlayerForYouScreen({
    required this.videoUrl,
    this.onControllerReady,
    Key? key, required this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerForYouScreen> createState() => _VideoPlayerForYouScreenState();
}

class _VideoPlayerForYouScreenState extends State<VideoPlayerForYouScreen> {
  late CustomVideoPlayerController _controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    final muteController = Get.find<MuteController>();

    // Verifica se já existe um controller para este vídeo
    if (Get.isRegistered<CustomVideoPlayerController>(tag: widget.videoUrl)) {
      _controller = Get.find<CustomVideoPlayerController>(tag: widget.videoUrl);
      if (!_controller.isInitialized.value) {
        _initializeController(muteController);
      } else {
        _controller.resume(); // Reativa se já estiver inicializado
      }
    } else {
      _controller = Get.put(
          CustomVideoPlayerController(),
          tag: widget.videoUrl,
          permanent: false // Importante: não manter permanente
      );
      _initializeController(muteController);
    }
  }

  Future<void> _initializeController(MuteController muteController) async {
    await _controller.initialize(
        widget.videoUrl,
        muted: muteController.isMuted.value
    );

    if (!_isDisposed && widget.onControllerReady != null) {
      widget.onControllerReady!(_controller);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Pausa o vídeo mas não descarta completamente
    _controller.pause();

    // Não dispose o controller aqui para permitir reutilização
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    final muteController = Get.find<MuteController>();

    return Obx(() {
      // Verifique se o controller está inicializado antes de usá-lo
      if (!_controller.isInitialized.value || !_controller.controller.value.isInitialized) {
        return Hero(
          tag: widget.thumbnailUrl+"forYou",
          child: Image.network(
            widget.thumbnailUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image, color: Colors.white));
            },
          ),
        );
      }
      final isInitialized = _controller.isInitialized.value && _controller.controller.value.isInitialized;
      return Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.thumbnailUrl+"forYou",
            child: Image.network(
              widget.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, color: Colors.white));
              },
            ),
          ),

          // VIDEO (fica por cima e aparece quando estiver pronto)
          AnimatedOpacity(
            opacity: isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              color: Colors.black,
              child: isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.controller.value.aspectRatio,
                child: VideoPlayer(_controller.controller),
              )
                  : const SizedBox.shrink(),
            ),
          ),

          // Botão de mute (mantido no canto superior direito)
          Positioned(
            top: 16,
            right: 16,
            child: Obx(() {
              return IconButton(
                icon: Icon(
                  Get.find<MuteController>().isMuted.value
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: Colors.white54,
                  size: 28,
                ),
                onPressed: () {
                  Get.find<MuteController>().toggleMute();
                },
              );
            }),
          ),


          Obx(() {
            final showControls = !_controller.isPlaying.value || _controller.isVideoEnded.value;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showControls ? 1.0 : 0.0,
              child: _controller.isVideoEnded.value
                  ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  await _controller.replay();
                },
                child: const Text(
                  "Assistir novamente",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white38, size: 80),
                    onPressed: () {
                      final pos = _controller.currentPosition;
                      _controller.seekTo(pos - const Duration(seconds: 10));
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      _controller.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white38,
                      size: 100,
                    ),
                    onPressed: () {
                      _controller.isPlaying.value
                          ? _controller.pause()
                          : _controller.play();
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white38, size: 80),
                    onPressed: () {
                      final pos = _controller.currentPosition;
                      _controller.seekTo(pos + const Duration(seconds: 10));
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}
