import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iuser/global.dart';
import 'package:iuser/home/profile/followersScreen/followers_screen.dart';
import 'package:iuser/home/profile/followingScreen/following_screen.dart';
import 'package:iuser/home/profile/profile_controller.dart';
import 'package:iuser/home/profile/video_player_profile.dart';
import 'package:iuser/settings/account_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../list_and_mapa/list_and_mapa.dart';

class ProfileScreen extends StatefulWidget {
  String? visitUserID;
  String? profileImage;

  ProfileScreen({this.visitUserID, this.profileImage});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController controllerProfile = Get.put(ProfileController());
  bool isFollowingUser = false;
  GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    controllerProfile.updateCurrentUserID(widget.visitUserID.toString());
    getIsFollowingValue();
  }

  getIsFollowingValue() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.visitUserID.toString())
        .collection("followers")
        .doc(currentUserID)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          isFollowingUser = true;
        });
      } else {
        setState(() {
          isFollowingUser = false;
        });
      }
    });
  }

  Future<void> launchUserSocialProfile(String socialLink) async {
    if (!await launchUrl(Uri.parse("https://" + socialLink))) {
      throw Exception("Could not launch " + socialLink);
    }
  }

  handleClickEvent(String choiceClicked) {
    switch (choiceClicked) {
      case "Settings":
        Get.to(AccountSettingsScreen());
        break;

      case "Logout":
        FirebaseAuth.instance.signOut();
        Get.snackbar("Logged Out", "You are logged out from the app.");
        Future.delayed(const Duration(milliseconds: 1000), () {
          SystemChannels.platform.invokeMethod("SystemNavigator.pop");
        });
        break;
    }
  }

  void readClickedThumbnailInfo({
    required List<Map<String, dynamic>> itemList,
    required int clickedIndex,
  }) async {
    var allVideosDocs = await FirebaseFirestore.instance.collection("videos").get();

    List<Map<String, dynamic>> matchedVideos = [];

    for (var item in itemList) {
      String? thumbnailUrl = item["thumbnailUrl"];
      if (thumbnailUrl == null) continue;

      for (var doc in allVideosDocs.docs) {
        if ((doc.data() as dynamic)["thumbnailUrl"] == thumbnailUrl) {
          matchedVideos.add(doc.data() as Map<String, dynamic>);
          break;
        }
      }
    }

    if (matchedVideos.isNotEmpty) {
      Get.to(
            () => VideoPlayerProfile(
          videoList: matchedVideos,
          startIndex: clickedIndex,
        ),
      );
    }
  }


  Widget buildImage(String urlImage) => ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: Image.network(urlImage, fit: BoxFit.cover, width: 50, height: 50),
  );

  Widget buildSection({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required Function(int index) onTap,
  }) {
    if (items.isEmpty) return SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        /*gradient: LinearGradient(
          colors: [Colors.grey.shade900.withOpacity(0.7), Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),*/
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => ListAndMapa(videoList: items));
                  },
                  child: const Text(
                    "Ver todos",
                    style: TextStyle(
                        color: Colors.greenAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemBuilder: (context, index) {
                var item = items[index];
                String url = item['thumbnailUrl'] ?? '';
                String artistSongName = item['artistSongName'] ?? '';

                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'thumb_${item["videoID"] ?? item["id"] ?? "thumb_$index"}',
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 12,
                            right: 12,
                            child: Text(
                              artistSongName.isNotEmpty ? artistSongName : "Vídeo",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: Offset(1, 1),
                                    blurRadius: 4,
                                  )
                                ],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controllerProfile) {
        if (controllerProfile.userMap.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              controllerProfile.userMap["userName"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              widget.visitUserID.toString() == currentUserID
                  ? PopupMenuButton<String>(
                onSelected: handleClickEvent,
                itemBuilder: (BuildContext context) {
                  return {"Settings", "Logout"}.map((String choiceClicked) {
                    return PopupMenuItem(
                      value: choiceClicked,
                      child: Text(choiceClicked),
                    );
                  }).toList();
                },
              )
                  : Container(),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Hero(
                    tag: widget.profileImage!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        widget.profileImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // followers - following - likes (mantém igual, só ajusta texto e espaçamento)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                                () => FollowingScreen(
                              visitedProfileUserID: widget.visitUserID.toString(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalFollowings"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Sigo",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white24,
                        width: 1,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                                () => FollowersScreen(
                              visitedProfileUserID: widget.visitUserID.toString(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalFollowers"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Seguem",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white24,
                        width: 1,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalLikes"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text("Likes", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Redes sociais com espaçamento
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if ((controllerProfile.userMap["userFacebook"] ?? "").isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(controllerProfile.userMap["userFacebook"]);
                            },
                            child: Image.asset("images/facebook.png", width: 40),
                          ),
                        ),
                      if ((controllerProfile.userMap["userInstagram"] ?? "").isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(controllerProfile.userMap["userInstagram"]);
                            },
                            child: Image.asset("images/instagram.png", width: 40),
                          ),
                        ),
                      if ((controllerProfile.userMap["userTwitter"] ?? "").isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(controllerProfile.userMap["userTwitter"]);
                            },
                            child: Image.asset("images/twitter.png", width: 40),
                          ),
                        ),
                      if ((controllerProfile.userMap["userYoutube"] ?? "").isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(controllerProfile.userMap["userYoutube"]);
                            },
                            child: Image.asset("images/youtube.png", width: 40),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Botões logout ou seguir/desseguir
                  if (widget.visitUserID.toString() == currentUserID)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await googleSignIn.signOut();
                          await FirebaseAuth.instance.signOut();
                          Get.snackbar(
                            'Sessão encerrada',
                            'Você saiu do app com sucesso.',
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Sair do Perfil",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 6,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isFollowingUser = !isFollowingUser;
                          });
                          controllerProfile.followUnFollowUser();
                        },
                        icon: Icon(
                          isFollowingUser ? Icons.person_remove : Icons.person_add,
                          color: Colors.white,
                        ),
                        label: Text(
                          isFollowingUser ? "Desseguir" : "Seguir",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowingUser ? Colors.grey : Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Sessões melhoradas:

                  buildSection(
                    title: "Flash",
                    icon: Icons.flash_on,
                    items: controllerProfile.userMap["flashList"] ?? [],
                    onTap: (index) {
                      readClickedThumbnailInfo(
                        itemList: controllerProfile.userMap["flashList"],
                        clickedIndex: index,
                      );
                    },
                  ),

                  buildSection(
                    title: "lugares",
                    icon: Icons.place,
                    items: controllerProfile.userMap["placeList"] ?? [],
                    onTap: (index) {
                      readClickedThumbnailInfo(
                        itemList: controllerProfile.userMap["placeList"],
                        clickedIndex: index,
                      );
                    },
                  ),

                  buildSection(
                    title: "Lojas",
                    icon: Icons.store,
                    items: controllerProfile.userMap["storeList"] ?? [],
                    onTap: (index) {
                      readClickedThumbnailInfo(
                        itemList: controllerProfile.userMap["storeList"],
                        clickedIndex: index,
                      );
                    },
                  ),

                  buildSection(
                    title: "Produtos",
                    icon: Icons.shopping_bag,
                    items: controllerProfile.userMap["productList"] ?? [],
                    onTap: (index) {
                      readClickedThumbnailInfo(
                        itemList: controllerProfile.userMap["productList"],
                        clickedIndex: index,
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
