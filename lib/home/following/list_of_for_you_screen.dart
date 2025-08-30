import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iuser/home/comments/comments_screen.dart';
import 'package:iuser/home/for_you/controller_for_you_videos.dart';
import 'package:iuser/home/for_you/profile_video.dart';

import '../for_you/for_you_screen.dart';

class ListOfForYouScreen extends StatefulWidget {
  const ListOfForYouScreen({Key? key}) : super(key: key);

  @override
  State<ListOfForYouScreen> createState() => _ListOfForYouScreenState();
}

class _ListOfForYouScreenState extends State<ListOfForYouScreen> {
  final ListOfForYouScreenController controllerVideosForYou = Get.put(
    ListOfForYouScreenController(),
  );

  Widget buildImage(String urlImage) => Container(
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
      return Container(
        height: 290, // Altura fixa para a lista horizontal
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controllerVideosForYou.forYouAllVideosList.length,
          itemBuilder: (context, index) {
            final eachVideoInfo = controllerVideosForYou.forYouAllVideosList[index];
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
                        ForYouScreen(initialIndex: index, thumbnailUrl: eachVideoInfo.thumbnailUrl!, ),
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
                width: 180, // Largura fixa para cada item
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[900],
                ),
                child: Column(
                  children: [
                    // Hero Image (thumbnail)
                    Hero(
                      tag: eachVideoInfo.thumbnailUrl!+"forYou",
                      child: buildImage(eachVideoInfo.thumbnailUrl!),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username (compacto)
                          Text(
                            "@" + eachVideoInfo.userName.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.abel(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Title (compacto)
                          Text(
                            eachVideoInfo.title.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.alexBrush(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Like and comment buttons (compactos)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 24,
                                    onPressed: () {
                                      controllerVideosForYou.likeOrUnlikeVideo(
                                        eachVideoInfo.postID.toString(),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.favorite_rounded,
                                      color: eachVideoInfo.likesList!.contains(
                                        FirebaseAuth.instance.currentUser!.uid,
                                      )
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    eachVideoInfo.likesList!.length.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 24,
                                    onPressed: () {
                                      Get.to(
                                        CommentsScreen(
                                          videoID: eachVideoInfo.postID.toString(),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.add_comment,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    eachVideoInfo.totalComments.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
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
      );
    });
  }
}