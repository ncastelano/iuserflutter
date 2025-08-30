import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/profile/profile_screen.dart';
import 'package:iuser/widgets/custom_video_player.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../flashs_page_controller.dart';

class FlashsFollow extends StatefulWidget {
  @override
  State<FlashsFollow> createState() => _FlashsFollowState();
}

class _FlashsFollowState extends State<FlashsFollow> with WidgetsBindingObserver {
  final FlashsPageController controllerFollowingVideos = Get.put(FlashsPageController());
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  bool _isVisaTriggered = false;


  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    WidgetsBinding.instance.addObserver(this);

    controllerFollowingVideos.getFollowingUsersVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }




  void _triggerVisaAction() {
    if (_isVisaTriggered) return;
    _isVisaTriggered = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      _isVisaTriggered = false;

      if (controllerFollowingVideos.followingAllVideosList.isNotEmpty &&
          _currentPageIndex < controllerFollowingVideos.followingAllVideosList.length) {
        final currentVideo = controllerFollowingVideos.followingAllVideosList[_currentPageIndex];
        if (currentVideo.postID != null) {
          controllerFollowingVideos.visaOrNotVisa(currentVideo.postID!);
        }
      }
    });
  }

  Widget buildImage(String urlImage) => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      image: DecorationImage(image: NetworkImage(urlImage), fit: BoxFit.cover),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _triggerVisaAction();
        return true;
      },
      child: Obx(() {
        return PageView.builder(
          controller: _pageController,
          itemCount: controllerFollowingVideos.followingAllVideosList.length,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            _currentPageIndex = index;
            _triggerVisaAction();  // Atualiza visa ou vídeo conforme a troca de página
          },
          itemBuilder: (context, index) {
            final video = controllerFollowingVideos.followingAllVideosList[index];

            return Stack(
              children: [
                CustomVideoPlayer(
                  videoUrl: video.videoUrl ?? "",
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          reverseTransitionDuration: Duration(milliseconds: 1000),
                                          transitionDuration: Duration(milliseconds: 1500),
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              ProfileScreen(
                                                visitUserID: video.userID ?? "",
                                                profileImage: video.userProfileImage ?? "",
                                              ),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: video.userProfileImage ?? "",
                                      child: buildImage(video.userProfileImage ?? ""),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "@${video.userName}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        timeago.format(video.publishedDateTime as DateTime, locale: 'pt_BR'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 62),
                            ],
                          ),
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                controllerFollowingVideos.visaOrNotVisa(video.postID.toString());
                              },
                              icon: Icon(
                                Icons.check,
                                size: 36,
                                color: (video.visaList ?? []).contains(FirebaseAuth.instance.currentUser!.uid)
                                    ? Colors.green
                                    : Colors.white38,
                              ),
                            ),
                            Text(
                              (video.visaList ?? []).length.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            IconButton(
                              onPressed: () {
                                controllerFollowingVideos.likeOrUnlikeVideo(video.postID.toString());
                              },
                              icon: Icon(
                                Icons.favorite,
                                size: 36,
                                color: video.likesList!.contains(FirebaseAuth.instance.currentUser!.uid)
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              video.likesList!.length.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            IconButton(
                              onPressed: () {
                                Get.to(() => CommentsScreen(videoID: video.postID.toString()));
                              },
                              icon: const Icon(Icons.comment, size: 32, color: Colors.white),
                            ),
                            Text(
                              video.totalComments.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 62),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  right: MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding: const EdgeInsets.only(right: 8),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Text(
                          video.descriptionTags ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          maxLines: 100,
                          softWrap: true,
                        ),
                      ),
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