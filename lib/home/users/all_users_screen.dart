import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/following/videos_screen.dart';
import 'package:iuser/home/profile/profile_screen.dart';
import '../bottom_bar/bottom_bar.dart';
import '../choose_type.dart';
import '../flashs_page.dart';
import '../mapa/mapa.dart';
import '../profile/profile_model.dart';
import '../list_of_profile/list_all_profile_controller.dart';
import '../profile/video_player_profile.dart';

class AllUserScreen extends StatefulWidget {
  @override
  _AllUserScreenState createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  final ListAllProfileController controllerProfiles = Get.put(ListAllProfileController());
  int currentPage = 0;
  final int itemsPerPage = 3;
  int selectedIndex = 2;


  Widget buildImage(String urlImage) => ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: Image.network(urlImage, fit: BoxFit.cover, width: 50, height: 50),
  );
  final List<Widget> pages = [
    Mapa(),
    const FlashsPage(),
    AllUserScreen(),
    const ChooseType(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 10),
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  hintText: 'Buscar usuários...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: selectedIndex,),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar perfis', style: TextStyle(color: Colors.redAccent)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum perfil encontrado', style: TextStyle(color: Colors.white70)));
          }

          final userDocs = snapshot.data!.docs;
          List<ProfileModel> allProfiles = userDocs
              .map((doc) => ProfileModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .where((profile) =>
          profile.name.toLowerCase().contains(searchQuery) ||
              profile.email.toLowerCase().contains(searchQuery))
              .toList()
            ..sort((a, b) {
              final aStars = a.totalStars ?? -1;
              final bStars = b.totalStars ?? -1;
              return bStars.compareTo(aStars);
            });

          final totalPages = (allProfiles.length / itemsPerPage).ceil();
          final startIndex = currentPage * itemsPerPage;
          final endIndex = (startIndex + itemsPerPage).clamp(0, allProfiles.length);
          final profiles = allProfiles.length > itemsPerPage
              ? allProfiles.sublist(startIndex, endIndex)
              : allProfiles;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: profiles.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    final userID = profile.id;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Hero(
                                tag: profile.image,
                                child: buildImage(profile.image),
                              ),
                              title: Text(profile.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              subtitle: Text(profile.email,
                                  style: GoogleFonts.poppins(color: Colors.white60)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: Duration(milliseconds: 800),
                                    pageBuilder: (context, animation, _) =>
                                        ProfileScreen(
                                            visitUserID: profile.id,
                                            profileImage: profile.image),
                                    transitionsBuilder: (context, animation, _, child) =>
                                        FadeTransition(opacity: animation, child: child),
                                  ),
                                );
                              },
                            ),
                            Obx(() {
                              final userVideos = controllerProfiles.allProfilesVideosList
                                  .where((video) => video.userID == userID)
                                  .toList();

                              if (userVideos.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                  child: Text("Nenhum vídeo encontrado",
                                      style: GoogleFonts.poppins(color: Colors.white38)),
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
                                        /*  Get.to(() => VideoPlayerProfile(
                                            clickedVideoID: userVideos[imgIndex].postID.toString(),
                                          ));*/
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
                ),
              ),

              if (allProfiles.length > itemsPerPage)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white24),
                        ),
                        child: Text("Anterior", style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 16),
                      Text("Página ${currentPage + 1} de $totalPages",
                          style: GoogleFonts.poppins(color: Colors.white70)),
                      SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: currentPage < totalPages - 1
                            ? () => setState(() => currentPage++)
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white24),
                        ),
                        child: Text("Próxima", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 60,
              )
            ],
          );
        },
      ),
    );
  }
}
