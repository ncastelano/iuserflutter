import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../models/post.dart';

class UsersScreenController extends GetxController {
  // Vídeos de usuários seguidos
  final Rx<List<Post>> followingVideosList = Rx<List<Post>>([]);
  List<Post> get followingAllVideosList => followingVideosList.value;

  // Todos os vídeos de todos os usuários
  final Rx<List<Post>> allVideosProfileList = Rx<List<Post>>([]);
  List<Post> get allProfilesVideosList => allVideosProfileList.value;

  @override
  void onInit() {
    super.onInit();
    getFollowingUsersVideos();
    getAllUsersVideos();
  }

  /// Busca os vídeos dos usuários que o atual está seguindo
  void getFollowingUsersVideos() async {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) return;

    final userDoc = await FirebaseFirestore.instance.collection("users").doc(currentUserID).get();
    if (!userDoc.exists || userDoc.data() == null) return;

    final List<dynamic> followList = (userDoc.data() as Map<String, dynamic>)["followList"] ?? [];

    if (followList.isEmpty) {
      followingVideosList.value = []; // evita erro no `whereIn`
      return;
    }

    followingVideosList.bindStream(
      FirebaseFirestore.instance
          .collection("videos")
          .where("userID", whereIn: followList)
          .orderBy("publishedDateTime", descending: true)
          .snapshots()
          .map((QuerySnapshot snapshotVideos) {
        return snapshotVideos.docs.map((doc) => Post.fromDocumentSnapshot(doc)).toList();
      }),
    );
  }

  /// Busca todos os vídeos de todos os usuários
  void getAllUsersVideos() {
    allVideosProfileList.bindStream(
      FirebaseFirestore.instance
          .collection("videos")
          .orderBy("publishedDateTime", descending: true)
          .snapshots()
          .map((QuerySnapshot snapshotVideos) {
        return snapshotVideos.docs.map((doc) => Post.fromDocumentSnapshot(doc)).toList();
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

  /// Função para curtir/descurtir um vídeo
  Future<void> likeOrUnlikeVideo(String videoID) async {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserID == null) return;

    final snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    final likesList = (snapshotDoc.data() as Map<String, dynamic>)["likesList"] ?? [];

    if (likesList.contains(currentUserID)) {
      await FirebaseFirestore.instance.collection("videos").doc(videoID).update({
        "likesList": FieldValue.arrayRemove([currentUserID]),
      });
    } else {
      await FirebaseFirestore.instance.collection("videos").doc(videoID).update({
        "likesList": FieldValue.arrayUnion([currentUserID]),
      });
    }
  }
}
