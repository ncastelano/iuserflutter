import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/profile/videos_page.dart';

class ProfileVideoPage extends StatefulWidget {
  final String uid;
  final String userProfileImage;

  const ProfileVideoPage({
    Key? key,
    required this.uid,
    required this.userProfileImage,
  }) : super(key: key);

  @override
  State<ProfileVideoPage> createState() => _ProfileVideoPageState();
}

class _ProfileVideoPageState extends State<ProfileVideoPage> {
  late List<dynamic> likesList = [];
  late List<dynamic> followList = [];
  late List<dynamic> friendsList = [];
  late Future<List<Map<String, dynamic>>> videos;
  Map<String, dynamic>? profileData;
  int likesCount = 0;
  int friendsCount = 0;
  int followersCount = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          profileData = snapshot.data() as Map<String, dynamic>;
          likesList = profileData?["likesList"] ?? [];
          followList = profileData?["followersList"] ?? [];
          likesCount = likesList.length;
          followersCount = followList.length;
          isFollowing = followList.contains(FirebaseAuth.instance.currentUser?.uid);
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> likeOrUnlike() async {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null || profileData == null) return;

    try {
      if (likesList.contains(currentUserID)) {
        await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
          "likesList": FieldValue.arrayRemove([currentUserID]),
        });
        setState(() {
          likesList.remove(currentUserID);
          likesCount--;
        });
      } else {
        await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
          "likesList": FieldValue.arrayUnion([currentUserID]),
        });
        setState(() {
          likesList.add(currentUserID);
          likesCount++;
        });
      }
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  Future<void> friendOrNotFriend() async {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null || profileData == null) return;

    try {
      if (friendsList.contains(currentUserID)) {
        await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
          "friendsList": FieldValue.arrayRemove([currentUserID]),
        });
        setState(() {
          friendsList.remove(currentUserID);
          friendsCount--;
        });
      } else {
        await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
          "friendsList": FieldValue.arrayUnion([currentUserID]),
        });
        setState(() {
          friendsList.add(currentUserID);
          friendsCount++;
        });
      }
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  Future<void> toggleFollow() async {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null || profileData == null) return;

    try {
      final userRef = FirebaseFirestore.instance.collection("users").doc(currentUserID);
      final profileRef = FirebaseFirestore.instance.collection("users").doc(widget.uid);

      if (isFollowing) {
        // Unfollow
        await userRef.update({
          "followingList": FieldValue.arrayRemove([widget.uid]),
        });
        await profileRef.update({
          "followersList": FieldValue.arrayRemove([currentUserID]),
        });
        setState(() {
          isFollowing = false;
          followersCount--;
        });
      } else {
        // Follow
        await userRef.update({
          "followingList": FieldValue.arrayUnion([widget.uid]),
        });
        await profileRef.update({
          "followersList": FieldValue.arrayUnion([currentUserID]),
        });
        setState(() {
          isFollowing = true;
          followersCount++;
        });
      }
    } catch (e) {
      print("Error updating follow status: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Profile Image with green border (mantido igual)
            Stack(
              children: [
                Hero(
                  tag: widget.uid,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      /*  border: Border.all(
                        color: Colors.green,
                        width: 5.0,
                      ),*/
                      image: DecorationImage(
                        image: NetworkImage(widget.userProfileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 30,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // Conteúdo adicionado do ProfileVideoPage
            if (profileData != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileData!["name"] ?? "Usuário",
                              style: GoogleFonts.abel(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileData!["email"] ?? "",
                              style: GoogleFonts.abel(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stats Row
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              followersCount.toString(),
                              style: GoogleFonts.abel(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Seguidores",
                              style: GoogleFonts.abel(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8), // Espaçamento
                            if (FirebaseAuth.instance.currentUser?.uid != widget.uid)
                              ElevatedButton(
                                onPressed: toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing ? Colors.red : Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  isFollowing ? "Seguindo" : "Seguir",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),

                        Column(
                          children: [
                            Text(
                              likesCount.toString(),
                              style: GoogleFonts.abel(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Curtidas",
                              style: GoogleFonts.abel(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8), // Espaçamento
                            IconButton(
                              onPressed: likeOrUnlike,
                              icon: Icon(
                                Icons.favorite,
                                size: 40,
                                color: likesList.contains(FirebaseAuth.instance.currentUser?.uid)
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            Text(
                              friendsCount.toString(),
                              style: GoogleFonts.abel(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Amigos",
                              style: GoogleFonts.abel(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8), // Espaçamento
                            IconButton(
                              onPressed: friendOrNotFriend,
                              icon: Icon(
                                Icons.person,
                                size: 40,
                                color: friendsList.contains(FirebaseAuth.instance.currentUser?.uid)
                                    ? Colors.green
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),




                  ],
                ),
              ),
            ] else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.abel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.abel(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}