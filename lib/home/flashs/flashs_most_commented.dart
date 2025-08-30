import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/widgets/custom_video_player.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:iuser/home/for_you/profile_video.dart';
import '../flashs_page_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class FlashsMostCommented extends StatefulWidget {
  @override
  State<FlashsMostCommented> createState() => _FlashsMostCommentedState();
}

class _FlashsMostCommentedState extends State<FlashsMostCommented> with WidgetsBindingObserver {
  final FlashsPageController controller = Get.put(FlashsPageController());
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    WidgetsBinding.instance.addObserver(this);
    _pageController.addListener(_handlePageChange);

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.removeListener(_handlePageChange);
    _triggerVisaAction();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _triggerVisaAction();
    }
  }

  void _handlePageChange() {
    final newIndex = _pageController.page?.round() ?? 0;
    if (newIndex != _currentPageIndex) {
      _triggerVisaAction();
      _currentPageIndex = newIndex;
    }
  }

  void _triggerVisaAction() {
    if (controller.forYouAllVideosList.isNotEmpty &&
        _currentPageIndex < controller.forYouAllVideosList.length) {
      final currentVideo = controller.forYouAllVideosList[_currentPageIndex];
      if (currentVideo.postID != null) {
        controller.visaOrNotVisa(currentVideo.postID!);
      }
    }
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
          itemCount: controller.forYouAllVideosList.length,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) => _currentPageIndex = index,
          itemBuilder: (context, index) {
            final video = controller.forYouAllVideosList[index];

            return Stack(
              children: [
                CustomVideoPlayer(videoUrl: video.videoUrl ?? ""),

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
                                      Get.to(() => ProfileVideo(uid: video.userID!, userProfileImage: video.userProfileImage!));
                                    },
                                    child: Hero(
                                      tag: video.userID!,
                                      child: buildImage(video.userProfileImage!),
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
                            // Botão de Visa (check)
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller.visaOrNotVisa(video.postID.toString());
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
                              ],
                            ),

                            // Botão de Like
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller.likeOrUnlikeVideo(video.postID.toString());
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
                                  "${video.likesList!.length}",
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),

                            // Botão de Comentários
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Get.to(() => CommentsScreen(videoID: video.postID.toString()));
                                  },
                                  icon: const Icon(Icons.comment, size: 32, color: Colors.white),
                                ),
                                Text(
                                  "${video.totalComments}",
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                const SizedBox(height: 62),
                              ],
                            ),
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