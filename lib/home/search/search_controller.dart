import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../mapa/ItemData.dart';

class MySearchController extends GetxController {
  final RxString selectedCategory = 'Usuário'.obs;
  final RxList<ItemData> filteredItems = <ItemData>[].obs;
  final Rx<ItemData?> selectedItem = Rx<ItemData?>(null);
  final RxString currentUserImage = ''.obs;
  final RxString currentUserUid = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchFilteredData();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      currentUserUid.value = uid;
      fetchCurrentUserImage();
    }
  }

  (IconData, Color) getTypeStyle(String type) {
    switch (type) {
      case 'Usuário':
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

  String getItemType(ItemData item) {
    if (item.isUser == 'true') return 'Usuário';
    if (item.isFlash == 'true') return 'Flash';
    if (item.isProduct == 'true') return 'Produto';
    if (item.isPlace == 'true') return 'Lugar';
    if (item.isStore == 'true') return 'Loja';
    return 'Desconhecido';
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

    if (category == 'Usuário') {
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
          isUser: 'true',
        );
      }).toList();

      filteredItems.value = users;
    } else if (category == 'Sigo') {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;

      final followingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .get();

      final followingIDs = followingSnap.docs.map((doc) => doc.id).toList();

      if (followingIDs.isEmpty) {
        filteredItems.clear();
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
          isUser: 'true',
        );
      }).toList();

      filteredItems.value = followedUsers;
    } else if (category.endsWith('Amigos')) {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;

      final followingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .get();

      final followingIDs = followingSnap.docs.map((doc) => doc.id).toList();

      if (followingIDs.isEmpty) {
        filteredItems.clear();
        return;
      }

      final videosSnap = await FirebaseFirestore.instance.collection('videos').get();

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
          isUser: null,
          isFlash: data['isFlash'] == true ? 'true' : null,
          isProduct: data['isProduct'] == true ? 'true' : null,
          isPlace: data['isPlace'] == true ? 'true' : null,
          isStore: data['isStore'] == true ? 'true' : null,
        );
      })
          .toList();

      filteredItems.value = filtered;
    } else {
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
          isUser: null,
          isFlash: data['isFlash'] == true ? 'true' : null,
          isProduct: data['isProduct'] == true ? 'true' : null,
          isPlace: data['isPlace'] == true ? 'true' : null,
          isStore: data['isStore'] == true ? 'true' : null,
        );
      }).toList();

      filteredItems.value = filtered;
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = value.trim().toLowerCase();

      if (query.isEmpty) {
        await fetchFilteredData();
        return;
      }

      filteredItems.value = filteredItems
          .where((item) => item.name?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }
}
