import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:iuser/global.dart';
import '../../models/post.dart';

class ListAllProfileController extends GetxController {
  final Rx<List<Post>> allVideosProfileList = Rx<List<Post>>([]);
  List<Post> get allProfilesVideosList => allVideosProfileList.value;


  @override
  void onInit() {
    super.onInit();
    getAllUsersVideos();
  }

  getAllUsersVideos() async {
    // Obtenha todos os vídeos, ordenados por data
    allVideosProfileList.bindStream(
      FirebaseFirestore.instance
          .collection("videos")
          .orderBy("publishedDateTime", descending: true)
          .snapshots()
          .map((QuerySnapshot snapshotVideos) {
        List<Post> allUsersVideos = [];

        for (var eachVideo in snapshotVideos.docs) {
          allUsersVideos.add(Post.fromDocumentSnapshot(eachVideo));
        }

        return allUsersVideos;
      }),
    );
  }

  likeOrUnlikeVideo(String videoID) async {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    // Se já curtiu
    if ((snapshotDoc.data() as dynamic)["likesList"].contains(currentUserID)) {
      await FirebaseFirestore.instance.collection("videos").doc(videoID).update({
        "likesList": FieldValue.arrayRemove([currentUserID]),
      });
    } else {
      // Se ainda não curtiu
      await FirebaseFirestore.instance.collection("videos").doc(videoID).update({
        "likesList": FieldValue.arrayUnion([currentUserID]),
      });
    }
  }
}
