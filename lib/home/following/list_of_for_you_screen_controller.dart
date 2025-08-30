import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../models/post.dart';

class ListOfForYouScreenController extends GetxController
{
  final Rx<List<Post>> forYouVideosList = Rx<List<Post>>([]);
  List<Post> get forYouAllVideosList => forYouVideosList.value;


  @override
  void onInit() {
    super.onInit();

    forYouVideosList.bindStream(
      FirebaseFirestore.instance
          .collection("videos")
          .where("isFlash", isEqualTo: true) // Filtro adicional
          .orderBy("totalComments", descending: true) // Ordenação
          .snapshots()
          .map((QuerySnapshot snapshotQuery) {
        List<Post> videosList = [];

        for (var eachVideo in snapshotQuery.docs) {
          videosList.add(Post.fromDocumentSnapshot(eachVideo));
        }

        return videosList;
      }),
    );
  }

  likeOrUnlikeVideo(String videoID) async
  {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid.toString();

    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    //if already Liked
    if((snapshotDoc.data() as dynamic)["likesList"].contains(currentUserID))
    {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update(
          {
            "likesList": FieldValue.arrayRemove([currentUserID]),
          });
    }
    //if NOT-Liked
    else
    {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update(
          {
            "likesList": FieldValue.arrayUnion([currentUserID]),
          });
    }
  }
}