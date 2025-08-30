import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../following/videos_screen.dart';
import '../profile/profile_model.dart';
import '../profile/profile_page.dart';
import '../list_of_profile/list_all_profile_controller.dart';

class ListAllProfile extends StatefulWidget {
  @override
  _ListAllProfileState createState() => _ListAllProfileState();
}

class _ListAllProfileState extends State<ListAllProfile> {
  final ListAllProfileController controllerVideos = Get.put(ListAllProfileController());
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  Widget buildImage(String urlImage) => ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: Image.network(
      urlImage,
      fit: BoxFit.cover,
      width: 50,
      height: 50,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purpleAccent, Colors.blueAccent, Colors.cyanAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Efeito de desfoque no fundo
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar em todos os usuários...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                ),
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: Colors.black.withOpacity(0.3), // Fundo do AppBar semi-transparente
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar perfis'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhum perfil encontrado'));
                }

                final userDocs = snapshot.data!.docs;
                List<ProfileModel> profiles = userDocs
                    .map((doc) => ProfileModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .where((profile) =>
                profile.name.toLowerCase().contains(searchQuery) ||
                    profile.email.toLowerCase().contains(searchQuery))
                    .toList();

                return ListView.builder(
                  itemCount: profiles.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    final userID = profile.id;

                    return Card(
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Hero(
                                tag: profile,
                                child: buildImage(profile.image),
                              ),
                              title: Text(profile.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              subtitle: Text(profile.email),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    reverseTransitionDuration: Duration(milliseconds: 1000),
                                    transitionDuration: Duration(milliseconds: 1500),
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ProfilePage(profile: profile),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            Obx(() {
                              final userVideos = controllerVideos.allProfilesVideosList
                                  .where((video) => video.userID == userID)
                                  .toList();

                              if (userVideos.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                  child: Text("Nenhum vídeo encontrado", style: TextStyle(color: Colors.grey)),
                                );
                              }

                              return SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: userVideos.length,
                                  itemBuilder: (context, imgIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.to(() => VideosScreen(
                                            videos: userVideos,
                                            initialIndex: imgIndex,
                                          ));
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            userVideos[imgIndex].thumbnailUrl.toString(),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
