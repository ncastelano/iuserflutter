import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayerController extends GetxController {
  late VideoPlayerController controller;
  RxBool isInitialized = false.obs;
  RxBool isPlaying = false.obs;
  RxBool isVideoEnded = false.obs;
  RxBool isMuted = false.obs;

  Duration get currentPosition => controller.value.position;

  Future<void> initialize(String videoUrl, {bool muted = false}) async {
    controller = VideoPlayerController.network(videoUrl);
    await controller.initialize();

    if (muted) {
      await controller.setVolume(0);
    } else {
      await controller.setVolume(1);
    }

    isInitialized.value = true;
    isVideoEnded.value = false;

    // Começar a reprodução após a inicialização
    controller.play();
    isPlaying.value = true;

    // Listener para detectar fim do vídeo
    controller.addListener(() {
      if (controller.value.position >= controller.value.duration) {
        isVideoEnded.value = true;
        isPlaying.value = false;
      }
    });
  }


  void _videoListener() {
    if (controller.value.position >= controller.value.duration) {
      isPlaying.value = false;
      isVideoEnded.value = true;
    }
  }

  void play() {
    controller.play();
    isPlaying.value = true;
    isVideoEnded.value = false;
  }


  void pause() {
    controller.pause();
    isPlaying.value = false;
  }

  void seekTo(Duration position) {
    controller.seekTo(position);
  }

  void resume() {
    if (controller.value.isInitialized) {
      controller.play();
      update(); // Notifica os listeners
    }
  }

  void cleanUp() {
    if (controller.value.isInitialized) {
      controller.pause();
      controller.dispose();
    }
  }

  Future<void> replay() async {



    await controller.pause(); // Pausa antes do seek
    await controller.seekTo(Duration.zero); // Espera o seek concluir
    await controller.play();
    isVideoEnded.value = false;
    isPlaying.value = true;
  }



  void toggleMute([bool? muteStatus]) {
    if (muteStatus != null) {
      // Se receber um valor específico, usa esse valor
      controller.setVolume(muteStatus ? 0 : 1);
    } else {
      // Se não receber parâmetro, alterna o estado atual
      controller.setVolume(controller.value.volume > 0 ? 0 : 1);
    }
    update();
  }

  @override
  void onClose() {
    controller.removeListener(_videoListener);
    controller.dispose();
    super.onClose();
  }
}
