import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/custom_video_player.dart';
import '../comments/comments_screen.dart';

class VideosScreen extends StatefulWidget {
  final List<dynamic> videos;
  final int initialIndex;

  const VideosScreen({Key? key, required this.videos, required this.initialIndex}) : super(key: key);

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late PageController _pageController;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideo(widget.initialIndex);
  }

  void _initializeVideo(int index) {
    _videoController = VideoPlayerController.network(widget.videos[index].videoUrl.toString())
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  likeOrUnlikeVideo(String videoID, String userID) async {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid;

    // 1. Busca o documento do vídeo
    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    var videoData = snapshotDoc.data() as Map<String, dynamic>;

    // 2. Verifica se o vídeo já foi curtido
    bool alreadyLiked = (videoData["likesList"] as List).contains(currentUserID);


    // 4. Atualiza os likes e o totalStars do dono do vídeo
    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference videoRef = FirebaseFirestore.instance.collection("videos").doc(videoID);
    DocumentReference userRef = FirebaseFirestore.instance.collection("users").doc(userID);

    if (alreadyLiked) {
      batch.update(videoRef, {
        "likesList": FieldValue.arrayRemove([currentUserID]),
      });
      batch.update(userRef, {
        "totalStars": FieldValue.increment(-1),
      });
    } else {
      batch.update(videoRef, {
        "likesList": FieldValue.arrayUnion([currentUserID]),
      });
      batch.update(userRef, {
        "totalStars": FieldValue.increment(1),
      });
    }

    // 5. Commit das alterações
    await batch.commit();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.videos.length,
        onPageChanged: (index) {
          _videoController.dispose();
          _initializeVideo(index);
        },
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return Stack(
            children: [

              //video
              CustomVideoPlayer(
                videoUrl: video.videoUrl.toString(),
              ),

              //left right - panels
              Column(
                children: [

                  const SizedBox(
                    height: 110,
                  ),

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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [

                                //username
                                Text(
                                  "@" + video.userName,
                                  style: GoogleFonts.abel(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                //description - tags
                                Text(
                                  video.descriptionTags,
                                  style: GoogleFonts.abel(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),



                              ],
                            ),
                          ),
                        ),

                        //right panel
                        Container(
                          width: 100,
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              //profile
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  width: 62,
                                  height: 62,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 4,
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: Image(
                                              image: NetworkImage(
                                                video.userProfileImage,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Like button - total Likes
                              Column(
                                children: [
                                  // StreamBuilder para atualizar tanto o botão de like quanto o contador de likes em tempo real
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("videos")
                                        .doc(video.videoID.toString())
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return Column(
                                          children: [
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.favorite_rounded,
                                                size: 40,
                                                color: Colors.white, // Estado inicial antes de carregar os dados
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                "0", // Exibe 0 caso os dados ainda não tenham carregado
                                                style: TextStyle(fontSize: 20, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      var likesList = (snapshot.data!.data() as Map<String, dynamic>)["likesList"] ?? [];
                                      bool isLiked = likesList.contains(FirebaseAuth.instance.currentUser!.uid);

                                      return Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              likeOrUnlikeVideo(video.videoID.toString(), video.userID.toString());
                                            },
                                            icon: Icon(
                                              Icons.favorite_rounded,
                                              size: 40,
                                              color: isLiked ? Colors.red : Colors.white,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              likesList.length.toString(), // Atualiza o contador em tempo real
                                              style: const TextStyle(fontSize: 20, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),

                              //comment button - total comments
                              Column(
                                children: [
                                  //comment button
                                  IconButton(
                                    onPressed: ()
                                    {
                                      Get.to(CommentsScreen(
                                        videoID: video.videoID,
                                      ));
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
                                      video.totalComments.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              //share button - total shares
                              Column(
                                children: [
                                  //share button
                                  IconButton(
                                    onPressed: ()
                                    {

                                    },
                                    icon: const Icon(
                                      Icons.share,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),



                              //profile circular animation
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors:
                                          [
                                            Colors.grey,
                                            Colors.white,
                                          ]
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image(
                                        image: NetworkImage(
                                          video.userProfileImage,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                            ],
                          ),
                                ]
                        ),

                    ),
                  ])
                    ),


                ],
              ),

            ],
          );
        },
      ),
    );
  }
}
