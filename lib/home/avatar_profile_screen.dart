import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iuser/global.dart';
import 'package:iuser/home/profile/followersScreen/followers_screen.dart';
import 'package:iuser/home/profile/followingScreen/following_screen.dart';
import 'package:iuser/home/profile/profile_controller.dart';
import 'package:iuser/home/profile/video_player_profile.dart';
import 'package:iuser/settings/account_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../full_screen_map.dart';

class AvatarProfileScreen extends StatefulWidget {
  String? visitUserID;

  AvatarProfileScreen({this.visitUserID});

  @override
  State<AvatarProfileScreen> createState() => _AvatarProfileScreenState();
}

class _AvatarProfileScreenState extends State<AvatarProfileScreen> {
  ProfileController controllerProfile = Get.put(ProfileController());
  bool isFollowingUser = false;
  GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleMapController? mapController;

  @override
  void initState() {
    // TODO: implement initState
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
      throw Exception("Could not launch" + socialLink);
    }
  }

  handleClickEvent(String choiceClicked) {
    switch (choiceClicked) {
      case "Settings":
        Get.to(AccountSettingsScreen());
        break;

      case "Logout":
        FirebaseAuth.instance.signOut();
        Get.snackbar("Logged Out", "you are logged out from the app.");
        Future.delayed(const Duration(milliseconds: 1000), () {
          SystemChannels.platform.invokeMethod("SystemNavigator.pop");
        });
        break;
    }
  }

  readClickedThumbnailInfo(String clickedThumbnailUrl) async {
    var allVideosDocs =
        await FirebaseFirestore.instance.collection("videos").get();

    for (int i = 0; i < allVideosDocs.docs.length; i++) {
      if (((allVideosDocs.docs[i].data() as dynamic)["thumbnailUrl"]) ==
          clickedThumbnailUrl) {
        /*Get.to(
          () => VideoPlayerProfile(
            clickedVideoID:
                (allVideosDocs.docs[i].data() as dynamic)["videoID"],
          ),
        );*/
      }
    }
  }

  Widget buildImage(String urlImage) => ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: Image.network(urlImage, fit: BoxFit.cover, width: 50, height: 50),
  );

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
              child: Column(
                children: [
                  Hero(
                    tag: controllerProfile.userMap["userImage"],
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            controllerProfile.userMap["userImage"],
                          ),
                          fit:
                              BoxFit
                                  .cover, // Garantir que a imagem cubra todo o círculo
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),

                  /* Hero(
                    tag:  controllerProfile.userMap["userImage"],
                    child: buildImage( controllerProfile.userMap["userImage"]),
                  ),*/
                  /* //user profile image
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      controllerProfile.userMap["userImage"],
                    ),
                  ),*/
                  const SizedBox(height: 16),

                  //followers - following - likes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //followings
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => FollowingScreen(
                              visitedProfileUserID:
                                  widget.visitUserID.toString(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalFollowings"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "Sigo",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      //space - margin
                      Container(
                        color: Colors.black54,
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),

                      //followers
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => FollowersScreen(
                              visitedProfileUserID:
                                  widget.visitUserID.toString(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalFollowers"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "Seguem",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      //space - margin
                      Container(
                        color: Colors.black54,
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),

                      //likes
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text(
                              controllerProfile.userMap["totalLikes"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text("Likes", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //user social links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if ((controllerProfile.userMap["userFacebook"] ?? "")
                          .isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(
                                controllerProfile.userMap["userFacebook"],
                              );
                            },
                            child: Image.asset(
                              "images/facebook.png",
                              width: 50,
                            ),
                          ),
                        ),

                      if ((controllerProfile.userMap["userInstagram"] ?? "")
                          .isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(
                                controllerProfile.userMap["userInstagram"],
                              );
                            },
                            child: Image.asset(
                              "images/instagram.png",
                              width: 50,
                            ),
                          ),
                        ),

                      if ((controllerProfile.userMap["userTwitter"] ?? "")
                          .isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(
                                controllerProfile.userMap["userTwitter"],
                              );
                            },
                            child: Image.asset("images/twitter.png", width: 50),
                          ),
                        ),

                      if ((controllerProfile.userMap["userYoutube"] ?? "")
                          .isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              launchUserSocialProfile(
                                controllerProfile.userMap["userYoutube"],
                              );
                            },
                            child: Image.asset("images/youtube.png", width: 50),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //follow - unfollow - signout
                  // Dentro do build ou wherever está seu botão atual
                  if (widget.visitUserID.toString() == currentUserID)
                    // === BOTÃO DE LOGOUT ===
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          GoogleSignIn googleSignIn = GoogleSignIn();
                          await FirebaseAuth.instance.signOut();
                          await googleSignIn.signOut();

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
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                      ),
                    )
                  else
                    // === BOTÃO DE FOLLOW / UNFOLLOW ===
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isFollowingUser = !isFollowingUser;
                          });

                          controllerProfile.followUnFollowUser();
                        },
                        icon: Icon(
                          isFollowingUser
                              ? Icons.person_remove
                              : Icons.person_add,
                          color: Colors.white,
                        ),
                        label: Text(
                          isFollowingUser ? "Desconectar" : "Conectar",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFollowingUser ? Colors.grey : Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // === MAPA AQUI ===
                  Hero(
                    tag: 'user_map',
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: LatLng(-10.787717, -65.336855),
                                zoom: 24,
                                tilt: 90,
                                bearing: 90,
                              ),
                              markers: controllerProfile.userMarkers.toSet(),
                              onMapCreated: (controller) {
                                mapController = controller;
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomGesturesEnabled: false,
                              scrollGesturesEnabled: false,
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        reverseTransitionDuration: Duration(
                                          milliseconds: 1500,
                                        ),
                                        transitionDuration: Duration(
                                          milliseconds: 1500,
                                        ),
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => FullScreenMap(
                                              userMarkers:
                                                  controllerProfile.userMarkers
                                                      .toSet(),
                                            ),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  //user's videos - thumbnails
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        controllerProfile.userMap["thumbnailsList"].length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: .7,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemBuilder: (context, index) {
                      String eachThumbnailUrl =
                          controllerProfile.userMap["thumbnailsList"][index];

                      return GestureDetector(
                        onTap: () {
                          readClickedThumbnailInfo(eachThumbnailUrl);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              eachThumbnailUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
