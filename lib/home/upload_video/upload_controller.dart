import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iuser/global.dart';
import 'package:iuser/home/home_screen.dart';
import 'package:iuser/models/post.dart';
import 'package:video_compress/video_compress.dart';

class UploadController extends GetxController {
  compressVideoFile(String videoFilePath) async {
    final compressedVideoFilePath = await VideoCompress.compressVideo(
      videoFilePath,
      quality: VideoQuality.LowQuality,
    );

    return compressedVideoFilePath!.file;
  }

  uploadCompressedVideoFileToFirebaseStorage(
    String videoID,
    String videoFilePath,
  ) async {
    UploadTask videoUploadTask = FirebaseStorage.instance
        .ref()
        .child("All Videos")
        .child(videoID)
        .putFile(await compressVideoFile(videoFilePath));

    TaskSnapshot snapshot = await videoUploadTask;

    String downloadUrlOfUploadedVideo = await snapshot.ref.getDownloadURL();

    return downloadUrlOfUploadedVideo;
  }

  getThumbnailImage(String videoFilePath) async {
    final thumbnailImage = await VideoCompress.getFileThumbnail(videoFilePath);

    return thumbnailImage;
  }

  uploadThumbnailImageToFirebaseStorage(
    String videoID,
    String videoFilePath,
  ) async {
    UploadTask thumbnailUploadTask = FirebaseStorage.instance
        .ref()
        .child("All Thumbnails")
        .child(videoID)
        .putFile(await getThumbnailImage(videoFilePath));

    TaskSnapshot snapshot = await thumbnailUploadTask;

    String downloadUrlOfUploadedThumbnail = await snapshot.ref.getDownloadURL();

    return downloadUrlOfUploadedThumbnail;
  }

  saveVideoInformationToFirestoreDatabase(
    String artistSongName,
    String descriptionTags,
    String videoFilePath,
    BuildContext context,
  ) async {
    try {
      DocumentSnapshot userDocumentSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

      String videoID = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload do vídeo e obtenção da URL
      String downloadUrlOfUploadedVideo =
          await uploadCompressedVideoFileToFirebaseStorage(
            videoID,
            videoFilePath,
          );

      // Upload da thumbnail e obtenção da URL
      String downloadUrlOfUploadedThumbnail =
          await uploadThumbnailImageToFirebaseStorage(videoID, videoFilePath);

      // Criando objeto de vídeo com URLs corretas
      Post videoObject = Post(
        userID: FirebaseAuth.instance.currentUser!.uid,
        userName: (userDocumentSnapshot.data() as Map<String, dynamic>)["name"],
        userProfileImage:
            (userDocumentSnapshot.data() as Map<String, dynamic>)["image"],
        postID: videoID,
        totalComments: 0,

        likesList: [],
        title: artistSongName,
        descriptionTags: descriptionTags,
        videoUrl: downloadUrlOfUploadedVideo,
        thumbnailUrl: downloadUrlOfUploadedThumbnail,
        publishedDateTime: DateTime.now(),
      );

      // Salvando no Firestore
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .set(videoObject.toJson());

      Get.to(HomeScreen());
      showProgressBar = false;

      Get.snackbar(
        "Video publicado!",
        "Seu video está pronto para ser exibido!",
      );
    } catch (errorMsg) {
      Get.snackbar(
        "Falha ao publicar!",
        "que pena, aconteceu alguma coisa...!",
      );
    }
  }
}
