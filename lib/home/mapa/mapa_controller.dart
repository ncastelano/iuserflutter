import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import 'ItemData.dart';

class MapaController extends GetxController {
  final RxString selectedCategory = 'Pessoas'.obs;
  final RxList<ItemData> filteredItems = <ItemData>[].obs;
  final RxList<ItemData> mapItems = <ItemData>[].obs;
  final Rx<ItemData?> selectedItem = Rx<ItemData?>(null);
  final RxSet<Marker> mapMarkers = <Marker>{}.obs;
  final RxBool visible = false.obs;
  final RxString currentUserImage = ''.obs;
  final RxString currentUserUid = ''.obs;

  GoogleMapController? mapController;
  Timer? _debounce;

  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-14.2350, -51.9253),
    zoom: 4,
  );

  @override
  void onInit() {
    super.onInit();
    fetchFilteredData();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      currentUserUid.value = uid;
      fetchCurrentUserImage();
    }
    requestLocationPermission();

  }

  Future<void> requestLocationPermission() async {
    await Permission.location.request();
  }

  Future<LatLng?> getCurrentLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return null;
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> fetchCurrentUserImage() async {
    final uid = currentUserUid.value;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        currentUserImage.value = data['image'] ?? '';
        currentUserUid.value = data['uid'] ?? '';
      }
    }
  }

  Future<void> fetchFilteredData() async {
    final category = selectedCategory.value;

    // 🔹 1. Usuários visíveis (públicos)
    if (category == 'Pessoas') {
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('visible', isEqualTo: true)
          .get();

      final users = usersSnap.docs.map((doc) {
        final data = doc.data();
        return ItemData(
          id: data['uid'] ?? '',
          image: data['image'] ?? '',
          name: data['namePage'],
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
          isUser: 'true',
        );
      }).toList();

      filteredItems.value = users;
      mapItems.value = users.where((e) => e.latitude != null && e.longitude != null).toList();
    }

    // 🔹 2. Usuários que o usuário atual segue (seguindo)
    else if (category == 'Sigo') {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;

      final followingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .get();

      final followingIDs = followingSnap.docs.map((doc) => doc.id).toList();

      if (followingIDs.isEmpty) {
        filteredItems.clear();
        mapItems.clear();
        mapMarkers.clear();
        return;
      }

      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('visible', isEqualTo: true)
          .get();

      final followedUsers = usersSnap.docs
          .where((doc) => followingIDs.contains(doc.id))
          .map((doc) {
        final data = doc.data();
        return ItemData(
          id: data['uid'] ?? '',
          image: data['image'] ?? '',
          name: data['namePage'],
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
          isUser: 'true',
        );
      }).toList();

      filteredItems.value = followedUsers;
      mapItems.value = followedUsers.where((e) => e.latitude != null && e.longitude != null).toList();
    }

    // 🔹 3. Categorias específicas de vídeos de amigos (flash amigos, produto amigos, etc)
    else if (category.endsWith('Amigos')) {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;

      final followingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .get();

      final followingIDs = followingSnap.docs.map((doc) => doc.id).toList();

      if (followingIDs.isEmpty) {
        filteredItems.clear();
        mapItems.clear();
        mapMarkers.clear();
        return;
      }

      final videosSnap = await FirebaseFirestore.instance
          .collection('videos')
          .get();

      final filtered = videosSnap.docs
          .where((doc) => followingIDs.contains(doc['userID']))
          .where((doc) {
        final data = doc.data();
        if (category == 'Flash Amigos') return data['isFlash'] == true;
        if (category == 'Produto Amigos') return data['isProduct'] == true;
        if (category == 'Lugar Amigos') return data['isPlace'] == true;
        if (category == 'Loja Amigos') return data['isStore'] == true;
        return false;
      })
          .map((doc) {
        final data = doc.data();
        return ItemData(
          id: data['videoID'] ?? doc.id,
          image: data['thumbnailUrl'] ?? '',
          name: data['artistSongName'],
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
          isUser: null,
          isFlash: data['isFlash'] == true ? 'true' : null,
          isProduct: data['isProduct'] == true ? 'true' : null,
          isPlace: data['isPlace'] == true ? 'true' : null,
          isStore: data['isStore'] == true ? 'true' : null,
        );
      })
          .toList();

      filteredItems.value = filtered;
      mapItems.value = filtered.where((e) => e.latitude != null && e.longitude != null).toList();
    }

    // 🔹 4. Categorias globais (todos os vídeos do Firestore, independente de seguir ou não)
    else {
      final videosSnap = await FirebaseFirestore.instance.collection('videos').get();

      final filtered = videosSnap.docs.where((doc) {
        final data = doc.data();
        return (category == 'Flash' && data['isFlash'] == true) ||
            (category == 'Produto' && data['isProduct'] == true) ||
            (category == 'Lugar' && data['isPlace'] == true) ||
            (category == 'Loja' && data['isStore'] == true);
      }).map((doc) {
        final data = doc.data();
        return ItemData(
          id: data['videoID'] ?? doc.id,
          image: data['thumbnailUrl'] ?? '',
          name: data['artistSongName'],
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
          isUser: null,
          isFlash: data['isFlash'] == true ? 'true' : null,
          isProduct: data['isProduct'] == true ? 'true' : null,
          isPlace: data['isPlace'] == true ? 'true' : null,
          isStore: data['isStore'] == true ? 'true' : null,
        );
      }).toList();

      filteredItems.value = filtered;
      mapItems.value = filtered.where((e) => e.latitude != null && e.longitude != null).toList();
    }

    await generateMarkers();
  }



  Future<void> generateMarkers() async {
    final List<Future<Marker>> futures = mapItems.map((item) async {
      final markerWidget = getWidgetMarker(item);

      // Pré-carrega a imagem se ela existir
      if (item.image.isNotEmpty) {
        try {
          await precacheImage(NetworkImage(item.image), Get.context!);
        } catch (e) {
          print('Erro ao carregar imagem: ${item.image}');
        }
      }

      final bitmap = await markerWidget.toBitmapDescriptor(
        logicalSize: const Size(300, 300),
        imageSize: const Size(300, 300),
      );

      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.latitude!, item.longitude!),
        icon: bitmap,
        onTap: () => selectedItem.value = item,
      );
    }).toList();

    mapMarkers.value = (await Future.wait(futures)).toSet();
  }


  Widget getWidgetMarker(ItemData item) {
    final hasImage = item.image.isNotEmpty;
    final type = getItemType(item);
    final (iconData, color) = getTypeStyle(type);

    final isCurrentUser = item.id == FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: isCurrentUser ? const EdgeInsets.all(4) : EdgeInsets.zero,
      decoration: isCurrentUser
          ? BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 4),
      )
          : BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      child: CircleAvatar(
        radius: 35,
        backgroundColor: isCurrentUser
            ? Colors.white // cor fixa para o usuário atual
            : Colors.transparent,
        backgroundImage: hasImage ? NetworkImage(item.image) : null,
        child: !hasImage ? Icon(iconData, color: Colors.white) : null,
      ),
    );

  }


  String getItemType(ItemData item) {
    if (item.isUser == 'true') return 'Pessoas';
    if (item.isFlash == 'true') return 'Flash';
    if (item.isProduct == 'true') return 'Produto';
    if (item.isPlace == 'true') return 'Lugar';
    if (item.isStore == 'true') return 'Loja';
    return 'Desconhecido';
  }

  (IconData, Color) getTypeStyle(String type) {
    switch (type) {
      case 'Pessoas':
        return (Icons.person, Colors.blueAccent);
      case 'Flash':
        return (Icons.flash_on, Colors.redAccent);
      case 'Produto':
        return (Icons.shopping_bag, Colors.green);
      case 'Lugar':
        return (Icons.place, Colors.purpleAccent);
      case 'Loja':
        return (Icons.store, Colors.orange);
      default:
        return (Icons.help_outline, Colors.grey);
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = value.trim().toLowerCase();

      if (query.isEmpty) {
        // 🔁 Se o campo de busca estiver vazio, recarrega os dados do Firestore
        await fetchFilteredData();
        return;
      }

      filteredItems.value = filteredItems
          .where((item) => item.name?.toLowerCase().contains(query) ?? false)
          .toList();

      mapItems.value = filteredItems
          .where((e) => e.latitude != null && e.longitude != null)
          .toList();

      await generateMarkers(); // <-- Atualiza os marcadores após busca
    });
  }


  Future<void> toggleVisibility() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();

    bool currentVisible = false;
    if (doc.exists && doc.data()!.containsKey('visible')) {
      currentVisible = doc['visible'] == true;
    }

    final newVisible = !currentVisible;
    await docRef.set({'visible': newVisible}, SetOptions(merge: true));
    // NÃO faça: visible.value = newVisible; porque o StreamBuilder já cuida disso
  }


  Future<void> loadInitialVisibility() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    visible.value = doc.data()?['visible'] == true;
  }
}
