import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iuser/widgets/avatar_profile.dart';
import '../../models/post.dart';
import '../avatar_profile_screen.dart';
import '../bottom_bar/bottom_bar.dart';
import 'detalhes_video_page.dart';
import 'mapa_page_controller.dart';

class MapaPage2 extends StatefulWidget {
  MapaPage2({Key? key}) : super(key: key);

  @override
  State<MapaPage2> createState() => _MapaPage2State();
}

class _MapaPage2State extends State<MapaPage2> {
  final MapaPageController controller = Get.put(MapaPageController());
  Timer? _debounce;
  GoogleMapController? _mapController;
  int selectedIndex = 0;
  // Cores da paleta
  final Color backgroundColor = Color(0xFF121212); // Preto (Dark)
  final Color secondaryColor = Colors.white; // Branco
  final Color inactiveColor = Colors.grey; // Cinza para itens inativos

  @override
  void initState() {
    super.initState();
    controller.mapType.value = MapType.normal;
  }


  void onTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  Widget _buildCategoryButton(String label, String category) {
    return Obx(() {
      final bool isSelected = controller.selectedCategory.value == category;

      return TextButton(
        onPressed: () {
          controller.filterByCategory(category);
        },
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.white54,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(label),
      );
    });
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: const CircleAvatar(
          radius: 34,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageAvatar(Post post) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: CircleAvatar(
          radius: 34,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(post.thumbnailUrl ?? ''),
          onBackgroundImageError: (_, __) {},
          child: (post.thumbnailUrl == null || post.thumbnailUrl!.isEmpty)
              ? const Icon(Icons.image_not_supported, color: Colors.white54)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 50, right: 15, left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Campo de busca
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 500),
                            () {
                          controller.filterMarkersByQuery(value);
                        },
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Procurar...',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white70, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Botão de tipo de mapa
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: PopupMenuButton<String>(
                    color: backgroundColor,
                    icon: Icon(Icons.layers, color: Colors.white, size: 20),
                    onSelected: (value) async {
                      if (value == 'normal') {
                        controller.mapType.value = MapType.normal;
                        _mapController?.setMapStyle(null);
                      } else if (value == 'satellite') {
                        controller.mapType.value = MapType.satellite;
                        _mapController?.setMapStyle(null);
                      } else if (value == 'custom') {
                        controller.mapType.value = MapType.normal;
                        String style = await DefaultAssetBundle.of(context)
                            .loadString('assets/map_style.json');
                        _mapController?.setMapStyle(style);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'custom',
                        child: Text('Minimalista', style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: 'normal',
                        child: Text('Detalhado', style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: 'satellite',
                        child: Text('Satélite', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Avatar do usuário com espaçamento e imagem redonda
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      reverseTransitionDuration: const Duration(milliseconds: 1000),
                      transitionDuration: const Duration(milliseconds: 1500),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AvatarProfileScreen(
                            visitUserID: FirebaseAuth.instance.currentUser!.uid,
                          ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: ClipOval(
                    child: AvatarProfile(
                      visitUserID: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

        body: SingleChildScrollView(
            child: IntrinsicHeight(
            child: Obx(() {
              if (controller.currentPosition.value.target.latitude == 0 &&
                  controller.currentPosition.value.target.longitude == 0) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Lista de thumbnails
                  SizedBox(
                    height: 100,
                    child: Obx(() {
                      if (controller.filteredPosts.isEmpty && controller.allPosts.isEmpty) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 6,
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          itemBuilder: (context, index) => _buildLoadingAvatar(),
                        );
                      } else if (controller.filteredPosts.isEmpty) {
                        return const Center(child: Text('Nenhum resultado encontrado'));
                      }

                      return FutureBuilder(
                        future: Future.wait(controller.filteredPosts.map((post) =>
                            precacheImage(NetworkImage(post.thumbnailUrl ?? ''), context)
                                .catchError((_) {})
                        ).toList()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.filteredPosts.length,
                              padding: const EdgeInsets.only(left: 16, right: 8),
                              itemBuilder: (context, index) => _buildLoadingAvatar(),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.filteredPosts.length,
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            itemBuilder: (context, index) {
                              final post = controller.filteredPosts[index];
                              return GestureDetector(
                                onTap: () {
                                  controller.selectPost(post);
                                  final cameraPosition = CameraPosition(
                                    target: LatLng(post.latitude!, post.longitude!),
                                    zoom: 24.0,
                                    tilt: 45.0,
                                    bearing: 45.0,
                                  );
                                  _mapController?.animateCamera(
                                    CameraUpdate.newCameraPosition(cameraPosition),
                                  );
                                },
                                child: _buildImageAvatar(post),
                              );
                            },
                          );
                        },
                      );
                    }),
                  ),

                  // Botões de categoria
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryButton('Flash', 'isFlash'),
                        _buildCategoryButton('Lugar', 'isPlace'),
                        _buildCategoryButton('Produto', 'isProduct'),
                        _buildCategoryButton('Loja', 'isStore'),
                      ],
                    ),
                  ),

                  // Mapa animado
                  Obx(() {
                    final mapaHeight = controller.selectedPost.value == null
                        ? MediaQuery.of(context).size.height - 333
                        : MediaQuery.of(context).size.height - 480;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                      child: SizedBox(
                        height: mapaHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GoogleMap(
                            initialCameraPosition: controller.currentPosition.value,
                            markers: controller.markers.value,
                            mapType: controller.mapType.value,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                              Get.find<MapaPageController>().onMapCreated(controller);
                            },

                            onTap: (_) => controller.deselectPost(),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Card do vídeo selecionado
                  Obx(() {
                    final post = controller.selectedPost.value;
                    if (post == null) return const SizedBox.shrink();

                    final userLatLng = controller.currentPosition.value.target;
                    final distanceMeters = Geolocator.distanceBetween(
                      userLatLng.latitude,
                      userLatLng.longitude,
                      post.latitude!,
                      post.longitude!,
                    );
                    final distanceText = distanceMeters > 1000
                        ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
                        : '${distanceMeters.toStringAsFixed(0)} m';

                    return GestureDetector(
                      onTap: () => Get.to(
                            () => DetalhesVideoPage(post: post, thumbnailUrl: post.thumbnailUrl),
                        transition: Transition.downToUp,
                        duration: const Duration(seconds: 1),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Hero(
                              tag: post.thumbnailUrl ?? "",
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  post.thumbnailUrl ?? '',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(post.title ?? 'Título da Música',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text(post.userName ?? 'Usuário',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.white54),
                                        const SizedBox(width: 4),
                                        Text('Distância: $distanceText',
                                            style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ),
    );
  }
}
