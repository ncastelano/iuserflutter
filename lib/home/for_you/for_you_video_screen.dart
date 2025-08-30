import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:iuser/home/for_you/controller_for_you_videos.dart';
import 'package:iuser/home/for_you/profile_video.dart';
import 'package:iuser/home/for_you/profile_video_page.dart';
import 'package:iuser/widgets/circular_image_animation.dart';
import 'package:iuser/widgets/custom_video_player.dart';

import '../profile/profile_page.dart';

class ForYouVideoScreen extends StatefulWidget {
  const ForYouVideoScreen({Key? key}) : super(key: key);

  @override
  State<ForYouVideoScreen> createState() => _ForYouVideoScreenState();
}

class _ForYouVideoScreenState extends State<ForYouVideoScreen> {
  final ListOfForYouScreenController controllerVideosForYou = Get.put(
    ListOfForYouScreenController(),
  );

  Widget buildImage(String urlImage) => Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8), // Optional rounded corners
     /* border: Border.all(
        color: Colors.transparent,
        width: 5.0,         // Border width
      ),*/
      image: DecorationImage(
        image: NetworkImage(urlImage),
        fit: BoxFit.cover,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () async {
            try {
              // Sign out from Firebase Auth
              await FirebaseAuth.instance.signOut();

              // Sign out from Google
              await GoogleSignIn().signOut();

              // Display a snackbar
              Get.snackbar('Você desconectou do iUser', 'Volte em breve!');
            } catch (e) {
              // If there's an error
              Get.snackbar('Error', 'Failed to log out: $e');
            }
          },
          child: Text('Sair', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Obx(() {
        return PageView.builder(
          itemCount: controllerVideosForYou.forYouAllVideosList.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final eachVideoInfo =
                controllerVideosForYou.forYouAllVideosList[index];
            String imageUrl = eachVideoInfo.userProfileImage!;
            return Stack(
              children: [
                //video
                CustomVideoPlayer(
                  videoUrl: eachVideoInfo.videoUrl.toString(),
                ),

                //left right - panels
                Column(
                  children: [
                    const SizedBox(height: 110),

                    //left right - panels
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          //left panel
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //username
                                  Text(
                                    "@" + eachVideoInfo.userName.toString(),
                                    style: GoogleFonts.abel(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  //description - tags
                                  Text(
                                    eachVideoInfo.descriptionTags.toString(),
                                    style: GoogleFonts.abel(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  //artist - song name
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "  " +
                                              eachVideoInfo.title
                                                  .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.alexBrush(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //right panel
                          Container(
                            width: 100,
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 4,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //profile
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        reverseTransitionDuration: Duration(milliseconds: 1000),
                                        transitionDuration: Duration(milliseconds: 1500),
                                        pageBuilder: (context, animation, secondaryAnimation) => ProfileVideo(
                                          uid: eachVideoInfo.userID!,
                                          userProfileImage: eachVideoInfo.userProfileImage!,
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
                                    tag: eachVideoInfo.userID!, // Usar o UID como tag
                                    child: buildImage(eachVideoInfo.userProfileImage!),
                                  ),

                                ),


                                //like button - total Likes
                                Column(
                                  children: [
                                    //like button
                                    IconButton(
                                      onPressed: () {
                                        controllerVideosForYou
                                            .likeOrUnlikeVideo(
                                              eachVideoInfo.postID.toString(),
                                            );
                                      },
                                      icon: Icon(
                                        Icons.favorite_rounded,
                                        size: 40,
                                        color:
                                            eachVideoInfo.likesList!.contains(
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid,
                                                )
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                    ),

                                    //total Likes
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        eachVideoInfo.likesList!.length
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                //comment button - total comments
                                Column(
                                  children: [
                                    //comment button
                                    IconButton(
                                      onPressed: () {
                                        Get.to(
                                          CommentsScreen(
                                            videoID:
                                                eachVideoInfo.postID
                                                    .toString(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_comment,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),

                                    //total comments
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        eachVideoInfo.totalComments.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),


                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
