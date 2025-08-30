
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iuser/home/profile/profile_controller.dart';

class AvatarProfile extends StatefulWidget {
  String? visitUserID;


  AvatarProfile({this.visitUserID, });

  @override
  State<AvatarProfile> createState() => _AvatarProfileState();
}

class _AvatarProfileState extends State<AvatarProfile> {
  ProfileController controllerProfile = Get.put(ProfileController());
  bool isFollowingUser = false;
  GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controllerProfile.updateCurrentUserID(widget.visitUserID.toString());


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

        return Hero(
          tag: controllerProfile.userMap["userImage"],
          child: ClipOval(
            child: Container(
              width: 50,  // Largura personalizada do avatar
              height: 50, // Altura personalizada do avatar
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(controllerProfile.userMap["userImage"]),
                  fit: BoxFit.cover, // Garantir que a imagem cubra todo o círculo
                ),
              ),
              child: Center(
                child: Container(
              width: 50,  // Largura personalizada do avatar
        height: 50, // Altura personalizada do avatar
        decoration: BoxDecoration(
       color: Colors.transparent
        ),
        ),
              ),
            ),
          ),
        );
      },
    );
  }
}
