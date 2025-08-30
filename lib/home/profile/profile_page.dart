import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iuser/home/profile/profile_model.dart';
import 'package:iuser/home/profile/videos_page.dart';

class ProfilePage extends StatefulWidget {
  final ProfileModel profile;

  const ProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late List<dynamic> likesList;
  late List<dynamic> followList;
  late Future<List<Map<String, dynamic>>> videos;
  late Stream<DocumentSnapshot> profileStream;
  int likesCount = 0;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    likesList = widget.profile.likesList ?? [];
    followList = widget.profile.followList ?? [];
    videos = fetchVideos();
    fetchCounts();
    profileStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.profile.id)
        .snapshots();
  }

  Future<void> likeOrUnlike(String uid) async {
    var currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) return;

    DocumentSnapshot snapshotDoc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!snapshotDoc.exists || snapshotDoc.data() == null) return;

    List<dynamic> updatedLikesList =
        (snapshotDoc.data() as Map<String, dynamic>)["likesList"] ?? [];

    if (updatedLikesList.contains(currentUserID)) {
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "likesList": FieldValue.arrayRemove([currentUserID]),
      });
      setState(() {
        likesList.remove(currentUserID);
      });
    } else {
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "likesList": FieldValue.arrayUnion([currentUserID]),
      });
      setState(() {
        likesList.add(currentUserID);
      });
    }
  }

  Future<void> followOrUnfollow(String uid) async {
    var currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) return;

    DocumentSnapshot snapshotDoc =
    await FirebaseFirestore.instance.collection("users").doc(currentUserID).get();

    if (!snapshotDoc.exists || snapshotDoc.data() == null) return;

    List<dynamic> updatedFollowList =
        (snapshotDoc.data() as Map<String, dynamic>)["followList"] ?? [];

    final currentUserRef = FirebaseFirestore.instance.collection("users").doc(currentUserID);
    final targetUserRef = FirebaseFirestore.instance.collection("users").doc(uid);

    if (updatedFollowList.contains(uid)) {
      // Unfollow: Remove from followList and followerList
      await currentUserRef.update({
        "followList": FieldValue.arrayRemove([uid]),
      });
      await targetUserRef.update({
        "followerList": FieldValue.arrayRemove([currentUserID]),
      });
      setState(() {
        followList.remove(uid);
      });
    } else {
      // Follow: Add to followList and followerList
      await currentUserRef.update({
        "followList": FieldValue.arrayUnion([uid]),
      });
      await targetUserRef.update({
        "followerList": FieldValue.arrayUnion([currentUserID]),
      });
      setState(() {
        followList.add(uid);
      });
    }
  }


  Future<List<Map<String, dynamic>>> fetchVideos() async {
    try {
      String userId = widget.profile.id; // Obtém o ID do perfil visitado

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("videos")
          .where("userID", isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> videos = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          "thumbnailUrl": data["thumbnailUrl"],
          "videoUrl": data["videoUrl"],
          "videoID": doc.id,
        };
      }).toList();

      return videos;
    } catch (e) {
      print("Erro ao buscar vídeos: $e");
      return [];
    }
  }

  Future<void> fetchCounts() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("users").doc(widget.profile.id).get();
      if (snapshot.exists) {
        setState(() {
          likesCount = (snapshot.data() as Map<String, dynamic>)['likesList']?.length ?? 0;
          followersCount = (snapshot.data() as Map<String, dynamic>)['followList']?.length ?? 0;
        });
      }
    } catch (e) {
      print("Erro ao buscar contagens: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purpleAccent,
            Colors.blueAccent,
            Colors.cyanAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Efeito de desfoque no fundo
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 00, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 400,
                      child: Hero(
                        tag: widget.profile,
                        child: Image.network(widget.profile.image, fit: BoxFit.cover),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(

                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.profile.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              widget.profile.email,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),


                                    ],
                                  ),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: profileStream, // Escuta as mudanças no perfil
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return Center(child: Text("Erro ao carregar perfil"));
                                      }

                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return Center(child: Text("Perfil não encontrado"));
                                      }

                                      var profileData = snapshot.data!.data() as Map<String, dynamic>;

                                      int likesCount = profileData['likesList']?.length ?? 0;
                                      int followersCount = profileData['followerList']?.length ?? 0;

                                      return Row(
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () => likeOrUnlike(widget.profile.id),
                                                icon: Icon(
                                                  Icons.favorite,
                                                  size: 30,
                                                  color: likesList.contains(
                                                    FirebaseAuth.instance.currentUser?.uid,
                                                  )
                                                      ? Colors.red
                                                      : Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "$likesCount",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 20),
                                          Column(
                                            children: [
                                              if (FirebaseAuth.instance.currentUser?.uid !=
                                                  widget.profile.id)
                                                TextButton(
                                                  onPressed: () => followOrUnfollow(widget.profile.id),
                                                  child: Text(
                                                    followList.contains(
                                                      widget.profile.id,
                                                    )
                                                        ? "Unfollow"
                                                        : "Follow",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: followList.contains(
                                                        widget.profile.id,
                                                      )
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                  ),
                                                ),
                                            Text(
                                                "$followersCount",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: videos,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }

                                  if (snapshot.hasError) {
                                    return Center(child: Text("Erro ao carregar vídeos"));
                                  }

                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return Center(child: Text("Nenhum vídeo encontrado"));
                                  }

                                  List<Map<String, dynamic>> videoList = snapshot.data!;

                                  return GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: videoList.length,
                                    itemBuilder: (context, index) {
                                      var video = videoList[index];

                                      return  Hero(
                                        tag: 'video-thumbnail-${video["videoID"]}', // Use um ID único para o Hero
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VideosPage(
                                                  videos: videoList,
                                                  initialIndex: index,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            color: Colors.transparent,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                video["thumbnailUrl"],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {
                              // Adicione ação para o botão more_vert aqui
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
