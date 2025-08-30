import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../global.dart';
import '../../models/post.dart';

class VideoControllerProfile extends GetxController {
  final Rx<List<Post>> videoFileList = Rx<List<Post>>([]);
  List<Post> get clickedVideoFile => videoFileList.value;

  final Rx<String> _videoID = "".obs;
  String get clickedVideoID => _videoID.value;
  Rx<String> _userID = "".obs;

  // Variável que mantém o estado de seguir
  RxBool isFollowingUser = false.obs;

  setVideoID(String vID) {
    _videoID.value = vID;
  }

  getClickedVideoInfo() {
    videoFileList.bindStream(
      FirebaseFirestore.instance
          .collection("videos")
          .snapshots()
          .map((QuerySnapshot snapshotQuery) {
        List<Post> videosList = [];

        for (var eachVideo in snapshotQuery.docs) {
          if (eachVideo["videoID"] == clickedVideoID) {
            videosList.add(Post.fromDocumentSnapshot(eachVideo));
          }
        }

        return videosList;
      }),
    );
  }

  // Este método vai buscar se o usuário está ou não seguindo outro usuário, em tempo real
  Stream<bool> isUserFollowing(String userID) {
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("followers")
        .doc(currentUserID)
        .snapshots()
        .map((snapshot) => snapshot.exists); // Retorna true se o documento existir
  }

  @override
  void onInit() {
    super.onInit();
    getClickedVideoInfo();
  }

  likeOrUnlikeVideo(String videoID) async {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid.toString();

    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    // Se já curtiu
    if ((snapshotDoc.data() as dynamic)["likesList"].contains(currentUserID)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likesList": FieldValue.arrayRemove([currentUserID]),
      });
    }
    // Se não curtiu
    else {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likesList": FieldValue.arrayUnion([currentUserID]),
      });
    }
  }

  followUnFollowUser(String userID) async {
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .collection("followers")
        .doc(currentUserID)
        .get();

    // Se o usuário já está seguindo
    if (document.exists) {
      // Remover seguidor
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userID)
          .collection("followers")
          .doc(currentUserID)
          .delete();

      // Remover da lista de seguidos
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("following")
          .doc(userID)
          .delete();

      // Decrementar o número de seguidores
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userID)
          .update({
        "totalFollowers": FieldValue.increment(-1),
      });
    } else {
      // Adicionar novo seguidor
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userID)
          .collection("followers")
          .doc(currentUserID)
          .set({});

      // Adicionar à lista de seguidos
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("following")
          .doc(userID)
          .set({});

      // Incrementar o número de seguidores
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userID)
          .update({
        "totalFollowers": FieldValue.increment(1),
      });
    }
  }
}
