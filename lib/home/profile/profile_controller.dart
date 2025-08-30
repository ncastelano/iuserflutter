import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iuser/global.dart';
import 'package:iuser/home/home_screen.dart';
import 'package:widget_to_marker/widget_to_marker.dart'; // Importar o pacote para converter widget em marcador

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _userMap = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get userMap => _userMap.value;
  Rx<String> _userID = "".obs;

  // Campos novos para o mapa
  List<Marker> userMarkers = [];
  LatLng initialLocation = const LatLng(0, 0);

  updateCurrentUserID(String visitUserID) {
    _userID.value = visitUserID;

    retrieveUserInformation();
    fetchUserVideosLocation();
  }

  retrieveUserInformation() async {
    DocumentSnapshot userDocumentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(_userID.value)
        .get();

    final userInfo = userDocumentSnapshot.data() as dynamic;

    String userName = userInfo["name"];
    String userEmail = userInfo["email"];
    String userImage = userInfo["image"];
    String userUID = userInfo["uid"];
    String userYoutube = userInfo["youtube"] ?? "";
    String userInstagram = userInfo["instagram"] ?? "";
    String userTwitter = userInfo["twitter"] ?? "";
    String userFacebook = userInfo["facebook"] ?? "";

    int totalLikes = 0;
    int totalFollowers = 0;
    int totalFollowings = 0;
    bool isFollowing = false;

    // Agora são listas de objetos Map, não só Strings
    List<Map<String, dynamic>> thumbnailsList = [];
    List<Map<String, dynamic>> flashList = [];
    List<Map<String, dynamic>> placeList = [];
    List<Map<String, dynamic>> storeList = [];
    List<Map<String, dynamic>> productList = [];

    var currentUserVideos = await FirebaseFirestore.instance
        .collection("videos")
        .orderBy("publishedDateTime", descending: true)
        .where("userID", isEqualTo: _userID.value)
        .get();

    for (var doc in currentUserVideos.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Adiciona o objeto completo
      thumbnailsList.add(data);

      if ((data["isFlash"] ?? false) == true) {
        flashList.add(data);
      }
      if ((data["isPlace"] ?? false) == true) {
        placeList.add(data);
      }
      if ((data["isStore"] ?? false) == true) {
        storeList.add(data);
      }
      if ((data["isProduct"] ?? false) == true) {
        productList.add(data);
      }

      totalLikes += (data["likesList"] as List).length;

    }

    var followersNumDocument = await FirebaseFirestore.instance
        .collection("users")
        .doc(_userID.value)
        .collection("followers")
        .get();
    totalFollowers = followersNumDocument.docs.length;

    var followingsNumDocument = await FirebaseFirestore.instance
        .collection("users")
        .doc(_userID.value)
        .collection("following")
        .get();
    totalFollowings = followingsNumDocument.docs.length;

    // Para garantir que o isFollowing seja atualizado corretamente aguardamos o resultado
    final followerDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(_userID.value)
        .collection("followers")
        .doc(currentUserID)
        .get();
    isFollowing = followerDoc.exists;

    _userMap.value = {
      "userName": userName,
      "userEmail": userEmail,
      "userImage": userImage,
      "userUID": userUID,
      "userYoutube": userYoutube,
      "userInstagram": userInstagram,
      "userTwitter": userTwitter,
      "userFacebook": userFacebook,
      "totalLikes": totalLikes.toString(),
      "totalFollowers": totalFollowers.toString(),
      "totalFollowings": totalFollowings.toString(),
      "isFollowing": isFollowing,
      "thumbnailsList": thumbnailsList,
      "flashList": flashList,
      "placeList": placeList,
      "storeList": storeList,
      "productList": productList,
    };

    update();
  }

  followUnFollowUser() async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(_userID.value)
        .collection("followers")
        .doc(currentUserID)
        .get();

    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userID.value)
          .collection("followers")
          .doc(currentUserID)
          .delete();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("following")
          .doc(_userID.value)
          .delete();

      _userMap.value.update("totalFollowers", (value) => (int.parse(value) - 1).toString());
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userID.value)
          .collection("followers")
          .doc(currentUserID)
          .set({});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("following")
          .doc(_userID.value)
          .set({});

      _userMap.value.update("totalFollowers", (value) => (int.parse(value) + 1).toString());
    }

    _userMap.value.update("isFollowing", (value) => !value);

    update();
  }

  updateUserSocialAccountLinks(String facebook, String youtube, String twitter, String instagram) async {
    try {
      final Map<String, dynamic> userSocialLinksMap = {
        "facebook": facebook,
        "youtube": youtube,
        "twitter": twitter,
        "instagram": instagram,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .update(userSocialLinksMap);

      Get.snackbar("Social Links", "Your social links are updated successfully.");

      Get.to(HomeScreen());
    } catch (errorMsg) {
      Get.snackbar("Error Updating Account", "Please try again.");
    }
  }

  // 🔥 Método novo para buscar localização dos vídeos
  fetchUserVideosLocation() async {
    QuerySnapshot videosSnapshot = await FirebaseFirestore.instance
        .collection("videos")
        .where("userID", isEqualTo: _userID.value)
        .get();

    userMarkers.clear();

    for (var doc in videosSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      double? lat = data['latitude'];
      double? lng = data['longitude'];

      if (lat != null && lng != null) {
        final markerWidget = Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: data['thumbnailUrl'] ?? '',
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.orange,
                      width: 6,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      data['thumbnailUrl'] ?? '',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.orange,
                  width: 6,
                ),
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Text(
                data['artistSongName'] ?? 'Vídeo',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );

        final bitmap = await markerWidget.toBitmapDescriptor(
          logicalSize: const Size(150, 150),
          imageSize: const Size(150, 150),
        );

        Marker marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          icon: bitmap,
          infoWindow: InfoWindow(
            title: data['artistSongName'] ?? 'Vídeo',
          ),
        );

        userMarkers.add(marker);

        if (userMarkers.length == 1) {
          initialLocation = LatLng(lat, lng);
        }
      }
    }

    update();
  }
}
