import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:iuser/global.dart';
import 'package:iuser/models/post.dart';

class
ControllerFollowingVideos extends GetxController
{
  final Rx<List<Post>> followingVideosList = Rx<List<Post>>([]);
  List<Post> get followingAllVideosList => followingVideosList.value;

  List<String> followingKeysList = [];


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getFollowingUsersVideos();
  }

  getFollowingUsersVideos() async
  {
    //1. get that followers
    var followingDocument = await FirebaseFirestore.instance
        .collection("users").doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .collection("following")
        .get();

    for(int i=0; i<followingDocument.docs.length; i++)
    {
      followingKeysList.add(followingDocument.docs[i].id);
    }

    //2. get videos of that following people
    followingVideosList.bindStream(
      FirebaseFirestore.instance
          .collection("videos")
          .where("isFlash", isEqualTo: true)
          .orderBy("publishedDateTime", descending: true)
          .snapshots()
          .map((QuerySnapshot snapshotVideos)
      {
        List<Post> followingPersonsVideos = [];

        for(var eachVideo in snapshotVideos.docs)
        {
          for(int i=0; i<followingKeysList.length; i++)
          {
            String followingPersonID = followingKeysList[i];

            if(eachVideo["userID"] == followingPersonID)
            {
              followingPersonsVideos.add(Post.fromDocumentSnapshot(eachVideo));
            }
          }
        }

        return followingPersonsVideos;
      }),
    );
  }


  Future<void> fetchFollowingVideos() async {
    var currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .get();

      if (!userDoc.exists || userDoc.data() == null) return;

      List<dynamic> followList =
          (userDoc.data() as Map<String, dynamic>)["followList"] ?? [];

      QuerySnapshot snapshotVideos = await FirebaseFirestore.instance
          .collection("videos")
          .where("userID", whereIn: followList)
          .orderBy("publishedDateTime", descending: true)
          .get();

      List<Post> fetchedVideos = snapshotVideos.docs
          .map((doc) => Post.fromDocumentSnapshot(doc))
          .toList();

      followingVideosList.value = fetchedVideos;
    } catch (e) {
      print("Erro ao buscar vídeos manualmente: $e");
    }
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