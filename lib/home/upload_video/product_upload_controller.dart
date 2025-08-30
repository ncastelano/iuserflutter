import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_compress/video_compress.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/post.dart';

class ProductUploadController extends GetxController {
  // Controllers de texto
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final storeIDController = TextEditingController();
  final productIDController = TextEditingController();

  // Estados reativos
  var videoFile = Rxn<File>();
  var thumbnailFile = Rxn<File>();
  var showTagField = false.obs;
  var isUploading = false.obs;
  var showOnMap = false.obs;
  var latitude = Rxn<double>();
  var longitude = Rxn<double>();

  final String selectedPostType = 'flash';

  void toggleTagField() {
    showTagField.value = !showTagField.value;
  }

  void setVideoFile(File file) {
    videoFile.value = file;
  }

  void setThumbnailFile(File file) {
    thumbnailFile.value = file;
  }

  Future<void> setShowOnMap(bool value) async {
    showOnMap.value = value;

    if (value) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Erro', 'Serviços de localização desativados.');
        showOnMap.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Erro', 'Permissão de localização negada.');
          showOnMap.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Erro', 'Permissão permanentemente negada.');
        showOnMap.value = false;
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;
    } else {
      latitude.value = null;
      longitude.value = null;
    }
  }

  Future<void> extractThumbnail(File videoFile) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoFile.path);
    if (thumbnail != null) setThumbnailFile(thumbnail);
  }

  Future<File?> compressVideo(String videoPath) async {
    final compressed = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.LowQuality,
    );
    return compressed?.file;
  }

  Future<String> uploadFile(File file, String path) async {
    final uploadTask = FirebaseStorage.instance.ref().child(path).putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> uploadVideo() async {
    if (videoFile.value == null || thumbnailFile.value == null) {
      Get.snackbar('Erro', 'Selecione um vídeo e uma capa!');
      return;
    }

    isUploading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Erro', 'Usuário não autenticado.');
        isUploading.value = false;
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      final postID = FirebaseFirestore.instance.collection("videos").doc().id;

      final compressedVideoFile = await compressVideo(videoFile.value!.path);
      if (compressedVideoFile == null) {
        Get.snackbar('Erro', 'Falha ao comprimir o vídeo.');
        isUploading.value = false;
        return;
      }

      final videoUrl = await uploadFile(compressedVideoFile, "All Videos/$postID");
      final thumbnailUrl = await uploadFile(thumbnailFile.value!, "All Thumbnails/$postID");
      final storeID = storeIDController.text.trim().isNotEmpty ? storeIDController.text.trim() : null;
      final productID = productIDController.text.trim().isNotEmpty ? productIDController.text.trim() : null;

      // Cria o objeto Post
      final post = Post(
        userID: user.uid,
        userName: userData["name"],
        userProfileImage: userData["image"],
        postID: postID,
        storeID: storeID,
        productID: productID,
        totalComments: 0,
        likesList: [],
        visaList: [],
        title: titleController.text.trim(),
        descriptionTags: descriptionController.text.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        publishedDateTime: DateTime.now(),
        latitude: latitude.value,
        longitude: longitude.value,
        isStore: selectedPostType == 'store',
        isFlash: selectedPostType == 'flash',
        isProduct: selectedPostType == 'product',
        isPlace: selectedPostType == 'place',
      );

      // Salva no Firestore usando toJson()
      await FirebaseFirestore.instance.collection("videos").doc(postID).set(post.toJson());

      Get.snackbar('Sucesso', 'Vídeo enviado com sucesso!');
      Get.offAllNamed('/main'); // Ou a rota da sua MainPage
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao enviar vídeo: $e');
    } finally {
      isUploading.value = false;
    }
  }


  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
