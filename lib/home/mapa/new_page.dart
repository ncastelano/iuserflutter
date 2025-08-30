import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import '../edit_location/edit_location.dart';
import '../profile/profile_screen.dart';
import 'ItemData.dart';
import 'card_mapa.dart';
import 'package:geocoding/geocoding.dart';





class NewPage extends StatefulWidget {
  const NewPage({Key? key}) : super(key: key);

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  final RxString selectedCategory = 'Usuário'.obs;
  final RxList<ItemData> filteredItems = <ItemData>[].obs;
  final RxList<ItemData> mapItems = <ItemData>[].obs;
  final Rx<ItemData?> selectedItem = Rx<ItemData?>(null);
  final RxSet<Marker> mapMarkers = <Marker>{}.obs;

  Timer? _debounce;
  final Color backgroundColor = const Color(0xFF121212);

  RxString currentUserImage = ''.obs;
  RxString currentUserUid = ''.obs; // não nullable


  GoogleMapController? _mapController;

  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-14.2350, -51.9253), // Brasil
    zoom: 4,

  );

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      currentUserUid.value = uid;
      fetchCurrentUserImage();
    }

    requestLocationPermission();
    fetchFilteredData();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print("Permissão concedida");
    } else {
      print("Permissão negada");
    }
  }

  Future<LatLng?> _getCurrentLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return null;

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _showEditLocationDialog() async {
    final TextEditingController controller = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditLocation()),
    );
  }

  Future<void> fetchCurrentUserImage() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUserUid.value).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && mounted) {
          currentUserImage.value = data['image'] ?? '';
          currentUserUid.value = data['uid'] ?? '';
        }
      }
    } catch (e) {
      currentUserImage.value = '';
      currentUserUid.value = '';
    }
  }

  Future<void> fetchFilteredData() async {
    if (selectedCategory.value == 'Usuário') {
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();

      final allUsers = usersSnap.docs.map((doc) {
        final data = doc.data();
        return ItemData(
          id: data['uid'] as String? ?? '',
          image: data['image'] as String? ?? '',
          name: data['namePage'] as String?,
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
          isUser: 'true',
        );
      }).toList();

      filteredItems.value = allUsers;
      mapItems.value = allUsers
          .where((item) => item.latitude != null && item.longitude != null)
          .toList();
    } else {
      final videosSnap = await FirebaseFirestore.instance.collection('videos').get();

      final filtered = videosSnap.docs.where((doc) {
        final data = doc.data();
        return (selectedCategory.value == 'Flash' && data['isFlash'] == true) ||
            (selectedCategory.value == 'Produto' && data['isProduct'] == true) ||
            (selectedCategory.value == 'Lugar' && data['isPlace'] == true) ||
            (selectedCategory.value == 'Loja' && data['isStore'] == true);
      }).map((doc) {
        final data = doc.data();
        return ItemData(
          id: data['videoID'] ?? doc.id, // ✅ usa videoID se disponível
          image: data['thumbnailUrl'] as String? ?? '',
          name: data['artistSongName'] as String?,
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
      mapItems.value = filtered
          .where((item) => item.latitude != null && item.longitude != null)
          .toList();
    }

    await generateMarkers();
  }

  Future<void> generateMarkers() async {
    final List<Future<Marker>> futures = mapItems.map((item) async {
      final markerWidget = getWidgetMarker(item);

      final bitmap = await markerWidget.toBitmapDescriptor(
        logicalSize: const Size(300, 300),
        imageSize: const Size(300, 300),
      );

      return Marker(
        markerId: MarkerId(item.name ?? 'item'),
        position: LatLng(item.latitude!, item.longitude!),
        icon: bitmap,
        onTap: () => selectedItem.value = item,
      );
    }).toList();

    final markers = await Future.wait(futures);
    mapMarkers.value = markers.toSet();
  }

  Widget _buildCategoryButton(String category) {
    return Obx(() {
      final bool isSelected = selectedCategory.value == category;
      return TextButton(
        onPressed: () {
          selectedCategory.value = category;
          selectedItem.value = null;
          fetchFilteredData();

        },
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.white54,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        child: Text(category),
      );
    });
  }

  Widget buildSearchBar() {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  final query = value.toLowerCase();
                  filteredItems.value = filteredItems
                      .where((item) =>
                  item.name != null &&
                      item.name!.toLowerCase().contains(query))
                      .toList();

                  mapItems.value = filteredItems
                      .where((item) =>
                  item.latitude != null && item.longitude != null)
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: selectedCategory.value,
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                  const BorderSide(color: Colors.white70, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                  const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final img = currentUserImage.value;
            final uid = currentUserUid.value;
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 1000),
                      pageBuilder: (context, animation, _) =>
                          ProfileScreen(
                            visitUserID: uid,
                            profileImage: img ,),
                      transitionsBuilder: (context, animation, _, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  );

            },
            child: Hero(
              tag: img,
              child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                  img.isNotEmpty ? NetworkImage(img) : null,
                  child: img.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
            ),
            );
          }),
        ],
      )),
    );
  }

  Widget _buildVisibilityButton(bool visible) {
    return Tooltip(
      message: visible ? 'Você está visível no mapa' : 'Você está invisível no mapa',
      child: GestureDetector(
        onTap: () async {
          final uid = currentUserUid.value;
          if (uid.isNotEmpty) {
            final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
            final doc = await docRef.get();

            bool currentVisible = false;

            // Se o campo existir, usa o valor; se não, assume true como padrão inicial
            if (doc.exists && doc.data()!.containsKey('visible')) {
              currentVisible = doc['visible'] == true;
            } else {
              // Campo ainda não existe, vamos definir como true inicialmente
              await docRef.set({'visible': true}, SetOptions(merge: true));
              currentVisible = true;
            }

            final newVisible = !currentVisible;

            // Atualiza o campo para o novo valor
            await docRef.set({'visible': newVisible}, SetOptions(merge: true));

            setState(() {}); // Rebuild para refletir o novo estado
          }
        },
        child: Container(
          height: 37,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black87,
            size: 22,
          ),
        ),
      ),
    );
  }



  // Função para detectar o tipo do item (única, reutilizável)
  String getItemType(ItemData item) {
    if (item.isUser == 'true') return 'Usuário';
    if (item.isFlash == 'true') return 'Flash';
    if (item.isProduct == 'true') return 'Produto';
    if (item.isPlace == 'true') return 'Lugar';
    if (item.isStore == 'true') return 'Loja';
    return 'Desconhecido';
  }

  // Função para obter ícone e cor conforme tipo (única)
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

  // Widget para criar o marker no mapa, usa as funções acima
  Widget getWidgetMarker(ItemData item) {
    final hasImage = item.image.isNotEmpty;
    final type = getItemType(item);
    final (iconData, color) = getTypeStyle(type);

    return CircleAvatar(
      radius: 25,
      backgroundColor: hasImage ? color : Colors.transparent,
      backgroundImage: hasImage ? NetworkImage(item.image) : null,
      child: !hasImage ? Icon(iconData, color: Colors.white) : null,
    );
  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: buildSearchBar(),
        ),
        body: Obx(() {
          return Column(
            children: [
            Container(
            height: 70,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return GestureDetector(
                  onTap: () {
                    if (item.latitude != null && item.longitude != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(item.latitude!, item.longitude!),
                            zoom: 22,
                            tilt: 90,

                          ),
                        ),
                      );
                      selectedItem.value = item;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: item.image.isNotEmpty ? Colors.white : Colors.red,
                          backgroundImage: item.image.isNotEmpty
                              ? NetworkImage(item.image)
                              : null,
                          child: item.image.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),

                      ],
                    ),
                  ),
                );

              },
            ),
          ),


          Container(
                height: 50,
                margin: const EdgeInsets.only(top: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _buildCategoryButton('Usuário'),
                      _buildCategoryButton('Flash'),
                      _buildCategoryButton('Lugar'),
                      _buildCategoryButton('Produto'),
                      _buildCategoryButton('Loja'),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: selectedItem.value == null
                          ? MediaQuery.of(context).size.height - 320
                          : MediaQuery.of(context).size.height - 470,
                      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child:Stack(
                          children: [
                            GoogleMap(
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                              initialCameraPosition: initialPosition,
                              onTap: (_) => selectedItem.value = null,
                              markers: mapMarkers.value,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false, // ⛔ desativa botão padrão
                            ),
                            // Botões posicionados no mapa
                            Positioned(
                              top: 17,
                              right: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Endereço completo
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(currentUserUid.value).get(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

                                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                                      final lat = data?['latitude'];
                                      final lng = data?['longitude'];

                                      if (lat == null || lng == null) return const Text('Endereço não encontrado');

                                      return FutureBuilder<List<Placemark>>(
                                        future: placemarkFromCoordinates(lat, lng),
                                        builder: (context, placeSnapshot) {
                                          if (!placeSnapshot.hasData || placeSnapshot.data == null) return const SizedBox();

                                          final place = placeSnapshot.data!.first;
                                          final address =
                                              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';

                                          return GestureDetector(
                                            onTap: _showEditLocationDialog,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min, // para o container ter largura mínima
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      address,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.settings,
                                                    size: 16,
                                                    color: Colors.black54,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 6),

                                  // Botão: Ir para minha localização
                                  Tooltip(
                                    message: 'Ir para minha localização',
                                    child: GestureDetector(
                                      onTap: () async {
                                        final position = await _getCurrentLocation();
                                        if (position != null) {
                                          _mapController?.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: position,
                                                zoom: 22,
                                                tilt: 90,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 37,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                        child: const Icon(Icons.my_location, color: Colors.black87, size: 22),
                                      ),
                                    ),
                                  ),



                                  // Botão: Atualizar o mapa
                                  Tooltip(
                                    message: 'Atualizar o mapa',
                                    child: GestureDetector(
                                      onTap: fetchFilteredData,
                                      child: Container(
                                        height: 37,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                        child: const Icon(Icons.refresh, color: Colors.black87, size: 22),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(currentUserUid.value).get(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        // Enquanto carrega, mostra botão eye off (invisível)
                                        return _buildVisibilityButton(false);
                                      }

                                      final data = snapshot.data!.data() as Map<String, dynamic>?;

                                      final visible = data?['visible'] == true; // se n existir, assume false (invisível)

                                      return _buildVisibilityButton(visible);
                                    },
                                  ),

                                ],
                              ),
                            )







                          ],
                        )

                      ),
                    ),


                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: selectedItem.value != null
                          ? Padding(
                        padding: const EdgeInsets.only(top: 8, left: 2, right: 2, bottom: 12),
                        child: CardMapa(
                          key: ValueKey(selectedItem.value!.id), // 👈 reinicia animação ao trocar
                          item: selectedItem.value!,
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),





                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}



