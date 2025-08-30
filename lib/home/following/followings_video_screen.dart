import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:iuser/home/following/controller_following_videos.dart';
import 'package:iuser/widgets/custom_video_player.dart';
import 'package:iuser/widgets/widget_video_player.dart';

class FollowingsVideoScreen extends StatefulWidget {
  const FollowingsVideoScreen({Key? key}) : super(key: key);

  @override
  State<FollowingsVideoScreen> createState() => _FollowingsVideoScreenState();
}

class _FollowingsVideoScreenState extends State<FollowingsVideoScreen> {
  final ControllerFollowingVideos controllerFollowingVideos = Get.put(ControllerFollowingVideos());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return PageView.builder(
          itemCount: controllerFollowingVideos.followingAllVideosList.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final video = controllerFollowingVideos.followingAllVideosList[index];

            return Stack(
              children: [
                // Background Video
                CustomVideoPlayer(videoUrl: video.videoUrl ?? ""),
                //WidgetVideoPlayer(videoFileUrl:video.videoUrl ?? "",extraBottomSpace: 400,),

                // Right side vertical column (everything inside)
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(
                                image: NetworkImage(video.userProfileImage ?? ""),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "@${video.userName}",
                            style: GoogleFonts.abel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),



                      // Description



                      // Music
                      Row(
                        children: [
                          const Icon(Icons.music_note, size: 20, color: Colors.white70),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title ?? "",
                                  style: GoogleFonts.alexBrush(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  video.descriptionTags ?? "",
                                  style: GoogleFonts.abel(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),

                          ),
                          Column(
                            children: [
                              // Like
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controllerFollowingVideos.likeOrUnlikeVideo(video.postID.toString());
                                    },
                                    icon: Icon(
                                      Icons.favorite,
                                      size: 30,
                                      color: video.likesList!.contains(FirebaseAuth.instance.currentUser!.uid)
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    video.likesList!.length.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 20),

                              // Comment
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Get.to(() => CommentsScreen(videoID: video.postID.toString()));
                                    },
                                    icon: const Icon(Icons.comment, size: 28, color: Colors.white),
                                  ),
                                  Text(
                                    video.totalComments.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 20),


                            ],
                          ),
                        ],
                      ),



                      // Actions: like, comment, share

                    ],
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
