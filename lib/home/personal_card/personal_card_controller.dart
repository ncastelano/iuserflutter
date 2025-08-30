import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PersonalCardController extends GetxController {
  final String uid;
  final String currentUserId;

  var isLoading = true.obs;
  var userData = Rxn<Map<String, dynamic>>();

  var isFollowing = false.obs;
  var followersCount = 0.obs;
  var followingCount = 0.obs;

  // Nova lista reativa de vídeos
  var videos = <Map<String, dynamic>>[].obs;
  var isLoadingVideos = true.obs;

  PersonalCardController({
    required this.uid,
    required this.currentUserId,
  });

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchVideos();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        userData.value = doc.data();
      } else {
        userData.value = null;
      }

      final followersSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('followers')
          .get();
      followersCount.value = followersSnap.docs.length;

      final followingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('following')
          .get();
      followingCount.value = followingSnap.docs.length;

      final isFollowingDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('followers')
          .doc(currentUserId)
          .get();

      isFollowing.value = isFollowingDoc.exists;
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVideos() async {
    try {
      isLoadingVideos.value = true;

      final snapshot = await FirebaseFirestore.instance
          .collection('videos')
          .where('userID', isEqualTo: uid)   // campo do usuário no vídeo
          .orderBy('publishedDateTime', descending: true)
          .get();

      videos.value = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erro ao buscar vídeos: $e');
    } finally {
      isLoadingVideos.value = false;
    }
  }


  Future<void> follow() async {
    if (isFollowing.value) return;

    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

    batch.set(userRef.collection('followers').doc(currentUserId), {'followedAt': FieldValue.serverTimestamp()});
    batch.set(currentUserRef.collection('following').doc(uid), {'followedAt': FieldValue.serverTimestamp()});

    await batch.commit();

    isFollowing.value = true;
    followersCount.value++;
  }

  Future<void> unfollow() async {
    if (!isFollowing.value) return;

    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

    batch.delete(userRef.collection('followers').doc(currentUserId));
    batch.delete(currentUserRef.collection('following').doc(uid));

    await batch.commit();

    isFollowing.value = false;
    followersCount.value--;
  }
}
