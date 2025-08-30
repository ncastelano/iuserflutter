
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bottom_bar/bottom_bar.dart';
import '../mapa/mapa_controller.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MapaController controller = Get.put(MapaController());
  final TextEditingController _controller = TextEditingController();
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;

      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Obx(() => Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Hero(
              tag: 'AppBar',
                child: Material(
                        child: TextField(
                          onChanged: controller.onSearchChanged,
                          decoration: InputDecoration(
                            hintText: controller.selectedCategory.value,
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.search, color: Colors.white70),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.white, width: 1.5),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 1000),
                          pageBuilder: (_, __, ___) => ProfileScreen(
                            visitUserID: controller.currentUserUid.value,
                            profileImage: controller.currentUserImage.value,
                          ),
                          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                        ),
                      );
                    },
                    child: Hero(
                      tag: controller.currentUserImage.value,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.transparent,
                        backgroundImage: controller.currentUserImage.value.isNotEmpty
                            ? NetworkImage(controller.currentUserImage.value)
                            : null,
                        child: controller.currentUserImage.value.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                  )
                ],
              ),
            )),
          ),
          bottomNavigationBar: BottomNavBar(selectedIndex: selectedIndex),
          body: Obx(() {
            return Column(
              children: [
                Hero(
                  tag: 'FilterList',
                  child: Material(
                    child: Container(
                    height: 70,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: controller.filteredItems.isEmpty
                          ? Center(
                        child: Text(
                          'Sem resultados encontrado',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.filteredItems[index];
                          return GestureDetector(
                            onTap: () {
                              controller.selectedItem.value = item;
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: item.image.isNotEmpty
                                      ? NetworkImage(item.image)
                                      : null,
                                  child: item.image.isEmpty
                                      ? const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Hero(
                  tag: 'FilterButton',
                  child: Material(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.only(top: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: ['Usuário', 'Flash', 'Lugar', 'Produto', 'Loja', 'Sigo', 'Flash Amigos', 'Lugar Amigos', 'Produto Amigos', 'Loja Amigos']
                              .map((category) => Obx(() {
                            final selected = controller.selectedCategory.value == category;
                            return TextButton(
                              onPressed: () async {
                                controller.selectedItem.value = null;
                                controller.selectedCategory.value = category;
                                await controller.fetchFilteredData();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: selected ? Colors.white : Colors.white54,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              child: Text(category),
                            );
                          }))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: controller.filteredItems.isEmpty
                      ? Center(
                    child: Text(
                      'Nenhum resultado encontrado.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: controller.filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.filteredItems[index];
                      final type = controller.getItemType(item);
                      final (icon, color) = controller.getTypeStyle(type);

                      return GestureDetector(
                        onTap: () {
                          // abrir detalhes ou vídeo
                        },
                        child: Card(
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: item.image.isNotEmpty
                                      ? Image.network(
                                    item.image,
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    height: 60,
                                    width: 60,
                                    color: Colors.black26,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name ?? 'Sem nome',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(icon, color: color, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            type,
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }),

        ),
      ),
    );
  }
}
