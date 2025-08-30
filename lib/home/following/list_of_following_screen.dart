import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:iuser/home/following/controller_following_videos.dart';
import 'package:iuser/widgets/custom_video_player.dart';

import 'followings_screen.dart';

class ListOfFollowingsScreen extends StatefulWidget {
  const ListOfFollowingsScreen({Key? key}) : super(key: key);

  @override
  State<ListOfFollowingsScreen> createState() => _ListOfFollowingsScreenState();
}

class _ListOfFollowingsScreenState extends State<ListOfFollowingsScreen> {
  final ControllerFollowingVideos controllerFollowingVideos = Get.put(ControllerFollowingVideos());



  Widget buildVideoThumbnail(String urlImage) => Container(
    width: 160,
    height: 120,
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
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Flashs das pessoas que você segue",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controllerFollowingVideos.followingAllVideosList.length,
              itemBuilder: (context, index) {
                final video = controllerFollowingVideos.followingAllVideosList[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        reverseTransitionDuration: Duration(
                          milliseconds: 1000,
                        ),
                        transitionDuration: Duration(milliseconds: 1500),
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                FollowingsScreen(initialIndex: index, thumbnailUrl:  video.thumbnailUrl!, ),
                        transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                            ) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(left: 16, bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[850],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video preview
                        Hero(
                            tag: video.thumbnailUrl!+"following",
                            child: buildVideoThumbnail(video.thumbnailUrl ?? "")),

                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundImage: NetworkImage(video.userProfileImage ?? ""),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "@${video.userName}",
                                      style: GoogleFonts.abel(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Title & description
                              Text(
                                video.title ?? "",
                                style: GoogleFonts.alexBrush(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                video.descriptionTags ?? "",
                                style: GoogleFonts.abel(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),

                              const SizedBox(height: 8),

                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 22,
                                        onPressed: () {
                                          controllerFollowingVideos.likeOrUnlikeVideo(video.postID.toString());
                                        },
                                        icon: Icon(
                                          Icons.favorite,
                                          color: video.likesList!.contains(FirebaseAuth.instance.currentUser!.uid)
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        video.likesList!.length.toString(),
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 22,
                                        onPressed: () {
                                          Get.to(() => CommentsScreen(videoID: video.postID.toString()));
                                        },
                                        icon: const Icon(Icons.comment, color: Colors.white),
                                      ),
                                      Text(
                                        video.totalComments.toString(),
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
