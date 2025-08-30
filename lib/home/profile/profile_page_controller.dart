import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:iuser/home/profile/profile_model.dart';

class ProfilePageController extends GetxController {
  final ProfileModel profile;
  ProfilePageController(this.profile);

  var likesList = <dynamic>[].obs;
  var followList = <dynamic>[].obs;
  var likesCount = 0.obs;
  var followersCount = 0.obs;
  var videos = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    likesList.value = profile.likesList ?? [];
    followList.value = profile.followList ?? [];
    fetchVideos();
    fetchCounts();
  }

  Future<void> likeOrUnlike() async {
    var currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) return;

    DocumentReference userDoc = FirebaseFirestore.instance.collection("users").doc(profile.id);
    DocumentSnapshot snapshot = await userDoc.get();

    if (!snapshot.exists) return;

    if (likesList.contains(currentUserID)) {
      await userDoc.update({"likesList": FieldValue.arrayRemove([currentUserID])});
      likesList.remove(currentUserID);
    } else {
      await userDoc.update({"likesList": FieldValue.arrayUnion([currentUserID])});
      likesList.add(currentUserID);
    }
  }

  Future<void> followOrUnfollow() async {
    var currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) return;

    DocumentReference userDoc = FirebaseFirestore.instance.collection("users").doc(profile.id);
    DocumentSnapshot snapshot = await userDoc.get();

    if (!snapshot.exists) return;

    if (followList.contains(currentUserID)) {
      await userDoc.update({"followList": FieldValue.arrayRemove([currentUserID])});
      followList.remove(currentUserID);
    } else {
      await userDoc.update({"followList": FieldValue.arrayUnion([currentUserID])});
      followList.add(currentUserID);
    }
  }

  Future<void> fetchVideos() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("videos")
          .where("userID", isEqualTo: profile.id)
          .get();

      videos.value = querySnapshot.docs.map((doc) {
        return {
          "thumbnailUrl": doc["thumbnailUrl"],
          "videoUrl": doc["videoUrl"],
          "videoID": doc.id,
        };
      }).toList();
    } catch (e) {
      print("Erro ao buscar vídeos: $e");
    }
  }

  Future<void> fetchCounts() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("users").doc(profile.id).get();
      if (snapshot.exists) {
        likesCount.value = (snapshot.data() as Map<String, dynamic>)['likesList']?.length ?? 0;
        followersCount.value = (snapshot.data() as Map<String, dynamic>)['followList']?.length ?? 0;
      }
    } catch (e) {
      print("Erro ao buscar contagens: $e");
    }
  }
}
