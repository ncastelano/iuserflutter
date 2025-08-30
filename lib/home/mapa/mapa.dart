import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bottom_bar/bottom_bar.dart';
import '../choose_type.dart';
import '../edit_location/edit_location.dart';
import '../flashs_page.dart';
import '../profile/profile_screen.dart';
import '../users/all_users_screen.dart';
import 'card_mapa.dart';
import 'mapa_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';


class Mapa extends StatefulWidget {
  Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final MapaController controller = Get.put(MapaController());
  final TextEditingController _controller = TextEditingController();
  int selectedIndex = 0;
  bool _loading = false;
  String? _currentAddress;
  LatLng? _currentLatLng;
  GoogleMapController? _mapController;

  Widget _buildIconBtn(IconData icon, String tooltip, VoidCallback onTap) {

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 37,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildVisibilityButton(bool visible) {
    return Tooltip(
      message: visible ? 'Você está visível no mapa' : 'Você está invisível no mapa',
      child: GestureDetector(
        onTap: () async {
          await controller.toggleVisibility();
          await controller.fetchFilteredData();
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


  void navigateWithSlideTransition({
    required BuildContext context,
    required Widget page,
    required bool toRight,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final beginOffset = Offset(toRight ? 1 : -1, 0);
          final endOffset = Offset.zero;
          final tween = Tween(begin: beginOffset, end: endOffset)
              .chain(CurveTween(curve: Curves.easeOut));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }



  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    final placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final address =
          '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';
      setState(() {
        _currentLatLng = latLng;
        _currentAddress = address;
        _controller.text = address; // atualiza o texto no TextField
      });
    }
  }

  Future<void> _locateMe() async {
    setState(() => _loading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão negada para acessar localização');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão negada permanentemente');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(position.latitude, position.longitude);

      // Atualiza o Firestore com a nova localização
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }

      // Atualiza o endereço e move o mapa
      await _updateAddressFromLatLng(latLng);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 17),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao localizar: $e')),
        );
      }
    }
    setState(() => _loading = false);
  }


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
          body: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Obx(() => Column(
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
                                if (item.latitude != null && item.longitude != null) {
                                  controller.mapController?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(item.latitude!, item.longitude!),
                                        zoom: 22,
                                        tilt: 90,
                                      ),
                                    ),
                                  );
                                  controller.selectedItem.value = item;
                                }
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
                                    backgroundImage: item.image.isNotEmpty ? NetworkImage(item.image) : null,
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
                            children: ['Pessoas','Flash','Lugar','Produto','Loja','Sigo','Flash Amigos','Lugar Amigos','Produto Amigos','Loja Amigos',]
                                .map((category) => Obx(() {
                              final selected = controller.selectedCategory.value == category;
                              return TextButton(
                                onPressed: () async {
                                  controller.selectedItem.value = null; // Zera antes
                                  controller.selectedCategory.value = category;
                                  await controller.fetchFilteredData(); // Aguarda carregamento (caso async)

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
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: controller.selectedItem.value == null
                              ? MediaQuery.of(context).size.height - 320
                              : MediaQuery.of(context).size.height - 420,
                          margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  onMapCreated: (mapController) => controller.mapController = mapController,
                                  initialCameraPosition: controller.initialPosition,
                                  onTap: (_) => controller.selectedItem.value = null,
                                  markers: controller.mapMarkers.value,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: false,
                                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                                  },
                                ),
                                Positioned(
                                  top: 17,
                                  right: 13,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(controller.currentUserUid.value)
                                            .get(),
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
                                              final address = '${place.street ?? ''}, ${place.locality ?? ''}';
                                              return Tooltip(
                                                message: 'Última localização salva',
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (_) => const EditLocation()),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(0),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            address,
                                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                                                            overflow: TextOverflow.ellipsis,

                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        const Icon(Icons.settings, size: 16, color: Colors.black54),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
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
                                      _buildIconBtn(Icons.add_location, 'Adicionar localização via gps', _loading ? () {} : (){
                                        _locateMe();
                                        controller.fetchFilteredData();
                                      }),
                                      _buildIconBtn(Icons.my_location, 'Ir para minha localização', () async {
                                        controller.fetchFilteredData();
                                        final pos = await controller.getCurrentLocation();
                                        if (pos != null) {
                                          controller.mapController?.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(target: pos, zoom: 22, tilt: 90),
                                            ),
                                          );
                                        }
                                      }),
                                      _buildIconBtn(Icons.refresh, 'Atualizar o mapa', controller.fetchFilteredData),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        (controller.selectedItem.value != null &&
                            controller.filteredItems.any((i) => i.id == controller.selectedItem.value!.id))
                            ? AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, left: 2, right: 2, bottom: 12),
                            child: CardMapa(
                              key: ValueKey(controller.selectedItem.value!.id),
                              item: controller.selectedItem.value!,
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),

                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }
}
