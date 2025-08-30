import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../PlaceScreen.dart';
import '../profile/profile_screen.dart';
import '../product/product_screen.dart';
import '../flash/flash_screen.dart';
import '../store/store_screen.dart';
import 'ItemData.dart';
import 'new_page.dart';

class CardMapa extends StatefulWidget {
  final ItemData item;

  const CardMapa({super.key, required this.item});

  @override
  State<CardMapa> createState() => _CardMapaState();
}

class _CardMapaState extends State<CardMapa> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  double? distanceInKm;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _calculateDistance();
  }

  void _calculateDistance() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final item = widget.item;

      if (item.latitude != null && item.longitude != null) {
        final distanceMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          item.latitude!,
          item.longitude!,
        );
        setState(() {
          distanceInKm = distanceMeters / 1000;
        });
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
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

  void navigateToScreen(ItemData item) {
    final type = getItemType(item);
    Widget screen;

    switch (type) {
      case 'Usuário':
        screen = ProfileScreen(
          visitUserID: item.id,
          profileImage: item.image,
        );
        break;
      case 'Lugar':
        screen = PlaceScreen(
          id: item.id,
          image: item.image,
        );
        break;
      case 'Produto':
        screen = ProductScreen(
          id: item.id,
          image: item.image,
        );
        break;
      case 'Flash':
        screen = FlashScreen(
          id: item.id,
          image: item.image,
        );
        break;
      case 'Loja':
        screen = StoreScreen(
          id: item.id,
          image: item.image,
        );
        break;
      default:
      // Caso não conhecido, não faz nada ou mostra um alerta
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        reverseTransitionDuration: const Duration(milliseconds: 1000),
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 1), // de baixo
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );

  }

  Widget _buildItemStack(ItemData item, Color color, IconData iconData) {
    if (item.isUser == 'true') return _buildUserCard(item, color, iconData);
    if (item.isFlash == 'true') return _buildFlashCard(item, color, iconData);
    if (item.isProduct == 'true') return _buildProductCard(item, color, iconData);
    if (item.isPlace == 'true') return _buildPlaceCard(item, color, iconData);
    if (item.isStore == 'true') return _buildStoreCard(item, color, iconData);

    return const SizedBox();
  }

  Widget _buildUserCard(ItemData item, Color color, IconData iconData) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: () => navigateToScreen(item),
          child: Hero(
            tag: item.image,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.transparent,
              backgroundImage: item.image.isNotEmpty ? NetworkImage(item.image) : null,
              child: item.image.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ),
        _buildIconBadge(color, iconData),
      ],
    );
  }

  Widget _buildFlashCard(ItemData item, Color color, IconData iconData) {
    return _buildDefaultCircle(item, color, iconData);
  }

  Widget _buildProductCard(ItemData item, Color color, IconData iconData) {
    return _buildDefaultCircle(item, color, iconData);
  }

  Widget _buildPlaceCard(ItemData item, Color color, IconData iconData) {
    return _buildDefaultCircle(item, color, iconData);
  }

  Widget _buildStoreCard(ItemData item, Color color, IconData iconData) {
    return _buildDefaultCircle(item, color, iconData);
  }

// Card genérico para todos exceto usuário
  Widget _buildDefaultCircle(ItemData item, Color color, IconData iconData) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: () => navigateToScreen(item),
          child: Hero(
            tag: item.image,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[800],
              backgroundImage: item.image.isNotEmpty ? NetworkImage(item.image) : null,
              child: item.image.isEmpty
                  ? const Icon(Icons.image_not_supported, color: Colors.white)
                  : null,
            ),
          ),
        ),
        _buildIconBadge(color, iconData),
      ],
    );
  }

// Reutiliza o badge com ícone
  Widget _buildIconBadge(Color color, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(iconData, size: 12, color: Colors.white),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final type = getItemType(item);
    final (iconData, color) = getTypeStyle(type);

    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
               // color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color, width: 1.8),
              /*  boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],*/
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemStack(item, color, iconData),

                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? 'Sem nome',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 4),
                              distanceInKm != null
                                  ? Text(
                                "${distanceInKm!.toStringAsFixed(1)} km de distância",
                                style: const TextStyle(color: Colors.white70),
                              )
                                  : const Text(
                                "Calculando distância...",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
