import 'dart:collection';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/following/controller_following_videos.dart';
import 'package:iuser/home/following/videos_screen.dart';
import 'package:iuser/home/profile/profile_screen.dart';
import 'package:iuser/home/users/users_screen_controller.dart';
import '../profile/profile_model.dart';
import '../profile/profile_page.dart';
import '../list_of_profile/list_all_profile_controller.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  final ControllerFollowingVideos controllerFollowingVideos = Get.put(
    ControllerFollowingVideos(),
  );
  final ListAllProfileController controllerProfiles = Get.put(
    ListAllProfileController(),
  );
  // 👇 Adicione essas duas linhas aqui:
  int currentPage = 0;
  final int itemsPerPage = 10;
  int currentFollowingPage = 0; // página atual da aba 'Seguindo'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget buildImage(String urlImage) => ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: Image.network(urlImage, fit: BoxFit.cover, width: 50, height: 50),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(

        preferredSize: Size.fromHeight(kToolbarHeight + 48), // 48 para o TabBar
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                border: Border(
                  bottom: BorderSide(color: Colors.white24, width: 0.5),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar usuários...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade400,
                      tabs: [Tab(text: "Seguindo"), Tab(text: "Todos")],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent,
                  Colors.blueAccent,
                  Colors.cyanAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Obx(() {
                  final Map<String, List<dynamic>> userVideosMap = LinkedHashMap();

                  for (var video in controllerFollowingVideos.followingAllVideosList) {
                    final uniqueKey = '${video.userName}_${video.userID}_${video.userProfileImage}';
                    userVideosMap.putIfAbsent(uniqueKey, () => []).add(video);
                  }

                  final filteredKeys = userVideosMap.keys.where((key) {
                    final displayUserName = key.split('_').first.toLowerCase();
                    return displayUserName.contains(searchQuery);
                  }).toList();

                  final totalPages = (filteredKeys.length / itemsPerPage).ceil();
                  final startIndex = currentFollowingPage * itemsPerPage;
                  final endIndex = (startIndex + itemsPerPage).clamp(0, filteredKeys.length);
                  final pagedKeys = filteredKeys.length > itemsPerPage
                      ? filteredKeys.sublist(startIndex, endIndex)
                      : filteredKeys;

                  return RefreshIndicator(
                    onRefresh: () async {
                      await controllerFollowingVideos.fetchFollowingVideos();
                    },
                    child: Column(
                      children: [
                        if (pagedKeys.isEmpty)
                          Expanded(
                            child: ListView(
                              children: [
                                SizedBox(height: 300),
                                Center(child: Text("Nenhum conteúdo encontrado.")),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: pagedKeys.length,
                              padding: const EdgeInsets.all(10),
                              itemBuilder: (context, index) {
                                final uniqueKey = pagedKeys[index];
                                final parts = uniqueKey.split('_');
                                final displayUserName = parts[0];
                                final userID = parts[1];
                                final userImage = parts[2];
                                final userVideos = userVideosMap[uniqueKey]!;

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
                                          leading: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  reverseTransitionDuration: Duration(milliseconds: 1000),
                                                  transitionDuration: Duration(milliseconds: 1500),
                                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                                      ProfileScreen(visitUserID: userID, profileImage: userImage),
                                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: Hero(
                                              tag: userImage,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(50),
                                                child: Image.network(userImage, width: 50, height: 50, fit: BoxFit.cover),
                                              ),
                                            ),
                                          ),
                                          title: Text("@$displayUserName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          subtitle: Text(""),
                                        ),
                                        SizedBox(
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
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Paginação: só aparece se houver mais de 2 usuários
                        if (filteredKeys.length > itemsPerPage)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: currentFollowingPage > 0
                                      ? () => setState(() => currentFollowingPage--)
                                      : null,
                                  child: Text("Anterior"),
                                ),
                                SizedBox(width: 16),
                                Text("Página ${currentFollowingPage + 1} de $totalPages"),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: currentFollowingPage < totalPages - 1
                                      ? () => setState(() => currentFollowingPage++)
                                      : null,
                                  child: Text("Próxima"),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),

              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent,
                  Colors.blueAccent,
                  Colors.cyanAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
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
                                          tag: profile.image,
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
                                                  ProfileScreen(
                                                      visitUserID: profile.id,
                                                      profileImage: profile.image),
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
                                        final userVideos = controllerProfiles.allProfilesVideosList
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
                          ),
                        ),

                        // Paginação só se tiver mais de 2 perfis
                        if (allProfiles.length > itemsPerPage)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: currentPage > 0
                                      ? () => setState(() => currentPage--)
                                      : null,
                                  child: Text("Anterior"),
                                ),
                                SizedBox(width: 16),
                                Text("Página ${currentPage + 1} de $totalPages"),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: currentPage < totalPages - 1
                                      ? () => setState(() => currentPage++)
                                      : null,
                                  child: Text("Próxima"),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
