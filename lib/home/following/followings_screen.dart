import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:iuser/home/for_you/profile_video.dart';
import 'package:iuser/widgets/video_player_for_you_screen.dart';
import '../../widgets/video_player_followings_screen.dart';
import '../custom_video_player_controller.dart';
import 'controller_following_videos.dart';

class FollowingsScreen extends StatefulWidget {
  final int initialIndex;
  final String thumbnailUrl;

  const FollowingsScreen({Key? key, required this.initialIndex, required this.thumbnailUrl}) : super(key: key);

  @override
  State<FollowingsScreen> createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
  final ControllerFollowingVideos controllerFollowings = Get.find<ControllerFollowingVideos>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    for (var video in controllerFollowings.followingAllVideosList) {
      if (Get.isRegistered<CustomVideoPlayerController>(tag: video.videoUrl)) {
        final controller = Get.find<CustomVideoPlayerController>(tag: video.videoUrl);
        controller.cleanUp();
        Get.delete<CustomVideoPlayerController>(tag: video.videoUrl);
      }
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: controllerFollowings.followingAllVideosList.length,
          onPageChanged: (index) {
            if (index > 0) {
              final prevVideo = controllerFollowings.followingAllVideosList[index - 1];
              Get.find<CustomVideoPlayerController>(tag: prevVideo.videoUrl).pause();
            }
            final currentVideo = controllerFollowings.followingAllVideosList[index];
            Get.find<CustomVideoPlayerController>(tag: currentVideo.videoUrl).play();
          },
          itemBuilder: (context, index) {
            final eachVideoInfo = controllerFollowings.followingAllVideosList[index];
            return Column(
              children: [
                Expanded(
                  flex: 3,
                  child: VideoPlayerFollowingsScreen(
                    videoUrl: eachVideoInfo.videoUrl!,
                    thumbnailUrl: widget.thumbnailUrl,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "@${eachVideoInfo.userName}",
                          style: GoogleFonts.abel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eachVideoInfo.descriptionTags ?? "",
                          style: GoogleFonts.abel(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eachVideoInfo.title ?? "",
                          style: GoogleFonts.alexBrush(fontSize: 14, color: Colors.white),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controllerFollowings.likeOrUnlikeVideo(eachVideoInfo.postID.toString());
                                    },
                                    icon: Icon(
                                      Icons.favorite,
                                      size: 32,
                                      color: eachVideoInfo.likesList!.contains(FirebaseAuth.instance.currentUser!.uid)
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    eachVideoInfo.likesList!.length.toString(),
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Get.to(() => CommentsScreen(videoID: eachVideoInfo.postID.toString()));
                                    },
                                    icon: const Icon(Icons.comment, size: 32, color: Colors.white),
                                  ),
                                  Text(
                                    eachVideoInfo.totalComments.toString(),
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
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
