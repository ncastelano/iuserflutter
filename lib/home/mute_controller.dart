import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'custom_video_player_controller.dart';
import 'for_you/controller_for_you_videos.dart';

class MuteController extends GetxController {
  var isMuted = false.obs;

  void toggleMute() {
    isMuted.toggle();

    // Aplica a todos os vídeos ativos
    for (var video in Get.find<ListOfForYouScreenController>().forYouAllVideosList) {
      if (Get.isRegistered<CustomVideoPlayerController>(tag: video.videoUrl)) {
        final videoController = Get.find<CustomVideoPlayerController>(tag: video.videoUrl);
        videoController.toggleMute(isMuted.value);
      }
    }
  }

  void setMute(bool value) {
    isMuted.value = value;
    // Aplica a todos os vídeos ativos quando muda o estado manualmente
    for (var video in Get.find<ListOfForYouScreenController>().forYouAllVideosList) {
      if (Get.isRegistered<CustomVideoPlayerController>(tag: video.videoUrl)) {
        Get.find<CustomVideoPlayerController>(tag: video.videoUrl)
            .toggleMute(value);
      }
    }
  }
}