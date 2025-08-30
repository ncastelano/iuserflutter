import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iuser/home/store_page.dart';
import 'package:iuser/home/upload_video/flash_upload.dart';
import 'package:iuser/home/upload_video/place_upload.dart';
import 'package:iuser/home/upload_video/product_upload.dart';
import 'package:iuser/home/upload_video/select_video_upload.dart';
import 'package:iuser/home/upload_video/store_upload.dart';
import 'package:iuser/home/users/all_users_screen.dart';

import 'bottom_bar/bottom_bar.dart';
import 'flashs_page.dart';
import 'mapa/mapa.dart';



class ChooseType extends StatefulWidget {
  const ChooseType({super.key});

  @override
  _ChooseTypeState createState() => _ChooseTypeState();
}

class _ChooseTypeState extends State<ChooseType> {
  bool _hasNoStore = true;
  String? _storeThumbnailUrl;  // Para armazenar o URL da thumbnail da loja
  String? _storePostID;
  int selectedIndex = 3;
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Chamar o método para verificar se o usuário tem loja quando o widget for carregado
  @override
  void initState() {
    super.initState();
    _checkIfUserHasStore(context);
  }

  Future<void> _checkIfUserHasStore(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userData = userDoc.data() as Map<String, dynamic>;
    final storePostID = userData['storePostID'];

    if (storePostID != null) {
      final storeDoc = await FirebaseFirestore.instance
          .collection("videos")
          .doc(storePostID)
          .get();

      final storeData = storeDoc.data() as Map<String, dynamic>;
      final thumbnailUrl = storeData['thumbnailUrl'];
      final postID = storeData['videoID'];

      // Atualize o estado para indicar que o usuário tem uma loja
      setState(() {
        _hasNoStore = false;
        _storeThumbnailUrl = thumbnailUrl;  // Armazenar o URL da thumbnail
        _storePostID = postID;
      });
    } else {
      setState(() {
        _hasNoStore = true;  // O usuário não tem loja
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher Tipo de Publicação'),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: selectedIndex),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hasNoStore
                ? _buildOption(
              context,
              title: "Criar Loja",
              color: Colors.blue,
              icon: Icons.store,
              onTap: () async {
                // Verificar novamente se o usuário tem loja antes de navegar para o upload
                await _checkIfUserHasStore(context);
                if (_hasNoStore) {
                  _navigateTo(context, StoreUpload());
                }
              },
            )
                : GestureDetector(
              onTap: () {
                // Redirecionar para a StorePage com o ID do post da loja
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StorePage(storePostID: _storePostID!),
                  ),
                );
              },
              child: Image.network(
                _storeThumbnailUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            _buildOption(
              context,
              title: "Produto",
              color: Colors.green,
              icon: Icons.shopping_bag,
              onTap: () => _navigateTo(context, ProductUpload()),
            ),
            _buildOption(
              context,
              title: "Flash",
              color: Colors.orange,
              icon: Icons.flash_on,
              onTap: () => _navigateTo(context, FlashUpload()),
            ),
            _buildOption(
              context,
              title: "Local",
              color: Colors.red,
              icon: Icons.place,
              onTap: () => _navigateTo(context, PlaceUpload()),
            ),
            _buildOption(
              context,
              title: "escolher",
              color: Colors.blue,
              icon: Icons.add,
              onTap: () => _navigateTo(context, SelectVideoUpload()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, {
        required String title,
        required Color color,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.4),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
