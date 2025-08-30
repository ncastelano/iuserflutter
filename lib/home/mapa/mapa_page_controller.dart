import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'; // para rootBundle

import '../../models/post.dart';

class MapaPageController extends GetxController {
  final Color backgroundColor = Color(0xFF121212);
  final Color primaryColor = Color(0xFFE8AF0B);
  final Color secondaryColor = Colors.white;
  final Color inactiveColor = Colors.grey;
  final Color borderColor = Colors.transparent;

  String? mapStyle;
  var markers = <Marker>{}.obs;
  var mapType = MapType.normal.obs;
  final allPosts = <Post>[].obs;
  var selectedPost = Rxn<Post>();
  var filteredPosts = <Post>[].obs;
  var selectedCategory = 'isFlash'.obs;
  late GoogleMapController mapController;

  var currentPosition = const CameraPosition(
    target: LatLng(-10.787717, -65.336855),
    zoom: 24,
    tilt: 90,

  ).obs;

  late VideoPlayerController sharedVideoController;

  @override
  void onInit() {
    super.onInit();

    Future.microtask(() async {
      await _getUserLocation();
      await _loadMapStyle();
      await loadAllVideosToMap();
    });
  }

  Future<void> _loadMapStyle() async {
    mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    // Aguarda até garantir que o estilo foi carregado
    if (mapStyle == null) {
      mapStyle = await rootBundle.loadString('assets/map_style.json');
    }

    mapController.setMapStyle(mapStyle);
  }


  void initVideo(String url) {
    sharedVideoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        sharedVideoController.setLooping(true);
        sharedVideoController.setVolume(0);
        sharedVideoController.play();
        update();
      });
  }

  void selectPost(Post post) {
    selectedPost.value = post;
    updateMarkers();
  }

  void deselectPost() {
    selectedPost.value = null;
    updateMarkers();
  }

  void updateMarkers() async {
    markers.value = await _generateMarkersFromPosts(filteredPosts);
    update();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Serviço de localização desabilitado.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        print('❌ Permissão de localização negada.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition.value = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 24,
      tilt: 90,

    );
  }

  List<Post> _sortPostsByCommentsDescending(List<Post> posts) {
    final sorted = [...posts];
    sorted.sort((a, b) => (b.totalComments ?? 0).compareTo(a.totalComments ?? 0));
    return sorted;
  }

  void filterByCategory(String category) async {
    selectedCategory.value = category;
    List<Post> filtered;

    switch (category) {
      case 'isFlash':
        filtered = allPosts.where((p) => p.isFlash == true).toList();
        break;
      case 'isPlace':
        filtered = allPosts.where((p) => p.isPlace == true).toList();
        break;
      case 'isProduct':
        filtered = allPosts.where((p) => p.isProduct == true).toList();
        break;
      case 'isStore':
        filtered = allPosts.where((p) => p.isStore == true).toList();
        break;
      default:
        filtered = allPosts;
    }

    final sorted = _sortPostsByCommentsDescending(filtered);
    filteredPosts.value = sorted;
    markers.value = await _generateMarkersFromPosts(sorted);
  }

  Future<Set<Marker>> _generateMarkersFromPosts(List<Post> posts) async {
    final markerFutures = posts.map((post) async {
      final isSelected = selectedPost.value?.postID == post.postID;

      // Garante que a imagem está carregada antes de gerar o marcador
      if ((post.thumbnailUrl ?? '').isNotEmpty) {
        try {
          await precacheImage(NetworkImage(post.thumbnailUrl!), Get.context!);
        } catch (e) {
          print('⚠️ Erro ao carregar imagem: ${post.thumbnailUrl}');
        }
      }

      final markerWidget = Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? primaryColor : borderColor,
                  width: isSelected ? 6 : 0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.network(
                post.thumbnailUrl ?? '',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? primaryColor : borderColor,
                width: isSelected ? 6 : 0,
              ),
              color: backgroundColor.withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Text(
              post.title ?? 'Título',
              style: TextStyle(
                color: secondaryColor,
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

      return Marker(
        markerId: MarkerId(post.postID ?? ''),
        position: LatLng(post.latitude!, post.longitude!),
        icon: bitmap,
        onTap: () => isSelected ? deselectPost() : selectPost(post),
      );
    }).toList();

    return (await Future.wait(markerFutures)).toSet();
  }

  void filterMarkersByQuery(String query) async {
    if (query.isEmpty) {
      final sorted = _sortPostsByCommentsDescending(allPosts);
      filteredPosts.value = sorted;
      markers.value = await _generateMarkersFromPosts(sorted);
    } else {
      final filtered = allPosts.where((post) {
        final titleLower = post.title?.toLowerCase() ?? '';
        final userLower = post.userName?.toLowerCase() ?? '';
        return titleLower.contains(query.toLowerCase()) || userLower.contains(query.toLowerCase());
      }).toList();

      final sorted = _sortPostsByCommentsDescending(filtered);
      filteredPosts.value = sorted;
      markers.value = await _generateMarkersFromPosts(sorted);
    }
  }

  Future<void> loadAllVideosToMap() async {
    final snapshot = await FirebaseFirestore.instance.collection("videos").get();

    final allPosts = snapshot.docs
        .map((doc) => Post.fromDocumentSnapshot(doc))
        .where((post) => post.latitude != null && post.longitude != null)
        .toList();

    this.allPosts.value = allPosts;

    final flashPosts = allPosts.where((post) => post.isFlash == true).toList();
    final sorted = _sortPostsByCommentsDescending(flashPosts);

    filteredPosts.value = sorted;
    markers.value = await _generateMarkersFromPosts(sorted);

    print("✅ Total de marcadores Flash carregados: ${markers.length}");
  }

  @override
  void onClose() {
    sharedVideoController.dispose();
    super.onClose();
  }
}
