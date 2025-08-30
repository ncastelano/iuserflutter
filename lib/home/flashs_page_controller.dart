import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:iuser/global.dart';
import 'package:iuser/models/post.dart';

import 'custom_video_player_controller.dart';

class FlashsPageController extends GetxController {
  // Videos da aba "Sigo"
  final Rx<List<Post>> followingVideosList = Rx<List<Post>>([]);
  List<Post> get followingAllVideosList => followingVideosList.value;

  // Videos da aba "Mais Comentados"
  final Rx<List<Post>> forYouVideosList = Rx<List<Post>>([]);
  List<Post> get forYouAllVideosList => forYouVideosList.value;

  // Lista de pessoas que o usuário segue
  List<String> followingKeysList = [];

  // Controllers ativos de vídeo (para controle de áudio e memória)
  final List<CustomVideoPlayerController> activeControllers = [];

  // Registra o controller quando o vídeo é inicializado
  void registerController(CustomVideoPlayerController controller) {
    if (!activeControllers.contains(controller)) {
      activeControllers.add(controller);
    }
  }

  // Pausa todos os vídeos ativos (ao trocar de aba, por exemplo)
  void pauseAllVideos() {
    for (final controller in activeControllers) {
      controller.pause();
    }
  }

  // Limpa todos os controllers (quando sai da tela, por exemplo)
  void disposeAllVideos() {
    for (final controller in activeControllers) {
      controller.dispose();
    }
    activeControllers.clear();
  }

  @override
  void onInit() {
    super.onInit();

    // Bind dos vídeos da aba "Mais Comentados"
    forYouVideosList.bindStream(
      FirebaseFirestore.instance
          .collection("videos")
          .orderBy("totalComments", descending: true)
          .snapshots()
          .map((QuerySnapshot snapshotQuery) {
        try {
          List<Post> videosList = [];
          final currentUserID = FirebaseAuth.instance.currentUser?.uid;

          if (currentUserID == null) return videosList;

          for (var eachVideo in snapshotQuery.docs) {
            final videoData = eachVideo.data() as Map<String, dynamic>;

            // Verifica se visaList existe e se não contém o currentUserID
            final visaList = videoData["visaList"] as List<dynamic>? ?? [];
            if (!visaList.contains(currentUserID)) {
              videosList.add(Post.fromDocumentSnapshot(eachVideo));
            }
          }

          return videosList;
        } catch (e) {
          print("Erro ao processar vídeos: $e");
          return [];
        }
      }),
    );

    // Carrega os vídeos da aba "Sigo"
    getFollowingUsersVideos();
  }

  Future<void> getFollowingUsersVideos() async {
    try {
      final currentUserID = FirebaseAuth.instance.currentUser!.uid;

      final followingSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("following")
          .get();

      followingKeysList = followingSnapshot.docs.map((doc) => doc.id).toList();

      followingVideosList.bindStream(
        FirebaseFirestore.instance
            .collection("videos")
            .orderBy("publishedDateTime", descending: true)
            .snapshots()
            .map((QuerySnapshot snapshotVideos) {
          List<Post> followingPersonsVideos = [];

          for (var eachVideo in snapshotVideos.docs) {
            final videoData = eachVideo.data() as Map<String, dynamic>;

            // Verifica se o usuário está seguindo E se não visualizou o vídeo
            if (followingKeysList.contains(videoData["userID"]) &&
                !(videoData["visaList"] as List<dynamic>? ?? []).contains(currentUserID)) {
              followingPersonsVideos.add(Post.fromDocumentSnapshot(eachVideo));
            }
          }

          return followingPersonsVideos;
        }),
      );
    } catch (e) {
      print("Erro ao buscar vídeos não visualizados: $e");
    }
  }

  // Caso queira buscar vídeos dos seguidos sem usar stream
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

  // Curtir ou descurtir vídeo
  Future<void> likeOrUnlikeVideo(String videoID) async {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    final likesList = (snapshotDoc.data() as dynamic)["likesList"] ?? [];

    if (likesList.contains(currentUserID)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likesList": FieldValue.arrayRemove([currentUserID]),
      });
    } else {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likesList": FieldValue.arrayUnion([currentUserID]),
      });
    }
  }


  Future<void> visaOrNotVisa(String videoID) async {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    final visaList = (snapshotDoc.data() as dynamic)["visaList"] ?? [];

    if (visaList.contains(currentUserID)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "visaList": FieldValue.arrayRemove([currentUserID]),
      });
    } else {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "visaList": FieldValue.arrayUnion([currentUserID]),
      });
    }
  }



}
