import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:iuser/home/for_you/controller_for_you_videos.dart';
import 'package:iuser/home/for_you/profile_video.dart';
import 'package:iuser/widgets/custom_video_player.dart';
import 'package:iuser/widgets/video_player_for_you_screen.dart';

import '../custom_video_player_controller.dart';

class ForYouScreen extends StatefulWidget {
  final int initialIndex;
  final String thumbnailUrl;
  const ForYouScreen({Key? key, required this.initialIndex, required this.thumbnailUrl}) : super(key: key);

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  final ListOfForYouScreenController controllerVideosForYou = Get.find<ListOfForYouScreenController>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    // Limpa todos os controllers de vídeo quando sair da tela
    for (var video in controllerVideosForYou.forYouAllVideosList) {
      if (Get.isRegistered<CustomVideoPlayerController>(tag: video.videoUrl)) {
        final controller = Get.find<CustomVideoPlayerController>(tag: video.videoUrl);
        controller.cleanUp();
        Get.delete<CustomVideoPlayerController>(tag: video.videoUrl);
      }
    }

    _pageController.dispose();
    super.dispose();
  }

  Widget buildImage(String urlImage) => Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      image: DecorationImage(
        image: NetworkImage(urlImage),
        fit: BoxFit.cover,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: controllerVideosForYou.forYouAllVideosList.length,
          onPageChanged: (index) {
            // Mantenha sua lógica de pausar/iniciar vídeos
            if (index > 0) {
              final prevVideo = controllerVideosForYou.forYouAllVideosList[index-1];
              Get.find<CustomVideoPlayerController>(tag: prevVideo.videoUrl).pause();
            }
            final currentVideo = controllerVideosForYou.forYouAllVideosList[index];
            Get.find<CustomVideoPlayerController>(tag: currentVideo.videoUrl).play();
          },
          itemBuilder: (context, index) {
            final eachVideoInfo = controllerVideosForYou.forYouAllVideosList[index];
            return Column(
              children: [
                // Parte superior - Vídeo em tela cheia
                Expanded(
                  flex: 3, // 3 partes do espaço para o vídeo
                  child: VideoPlayerForYouScreen(
                    videoUrl: eachVideoInfo.videoUrl!,
                    thumbnailUrl: widget.thumbnailUrl,
                  )

                ),

                // Parte inferior - Controles e informações
                Expanded(
                  flex: 1, // 1 parte do espaço para os controles
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome de usuário e descrição
                        Text(
                          "@${eachVideoInfo.userName}",
                          style: GoogleFonts.abel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          eachVideoInfo.descriptionTags.toString(),
                          style: GoogleFonts.abel(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          eachVideoInfo.title.toString(),
                          style: GoogleFonts.alexBrush(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),

                        // Linha de botões
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Botão de perfil
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileVideo(
                                        uid: eachVideoInfo.userID!,
                                        userProfileImage: eachVideoInfo.userProfileImage!,
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(eachVideoInfo.userProfileImage!),
                                ),
                              ),

                              // Botão de like
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controllerVideosForYou.likeOrUnlikeVideo(
                                        eachVideoInfo.postID.toString(),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.favorite_rounded,
                                      size: 32,
                                      color: eachVideoInfo.likesList!.contains(
                                        FirebaseAuth.instance.currentUser!.uid,
                                      ) ? Colors.red : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    eachVideoInfo.likesList!.length.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              // Botão de comentários
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Get.to(
                                        CommentsScreen(
                                          videoID: eachVideoInfo.postID.toString(),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.comment,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    eachVideoInfo.totalComments.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              // Espaço vazio para balancear
                              SizedBox(width: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}