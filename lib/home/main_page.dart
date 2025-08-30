import 'package:flutter/material.dart';
import 'package:iuser/home/mapa/new_page.dart';
import 'package:iuser/iuser_effect/iuser_effect.dart'; // Importe seu IUserEffect
import 'package:iuser/home/flashs_page.dart';
import 'package:iuser/home/users/all_users_screen.dart';

import 'choose_type.dart';
import 'mapa/mapa_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [

    MapaPage2(),
    FlashsPage(),
    AllUserScreen(),
    ChooseType(),
  ];

  final List<Map<String, dynamic>> navItems = [
    {
      'title': 'Teste',
      'icon': Icons.location_on,
    },
    {
      'title': 'Flash',
      'icon': Icons.web_stories,
    },
    {
      'title': 'Pessoas',
      'icon': Icons.people,
    },
    {
      'title': 'Upload',
      'icon': Icons.add,
    },
  ];

  // Cores da paleta
  final Color backgroundColor = Colors.black;//const Color(0xFF121212); // Preto (Dark)
  final Color primaryColor = Colors.white; //const Color(0xFFFFFFFF); // Laranja vibrante
  final Color inactiveColor =  Colors.grey;//Color(0x5FFFFFFF);  // Cinza para itens inativos

  // Chave para controlar o IUserEffect
  final GlobalKey<IUserEffectState> iuserEffectKey = GlobalKey<IUserEffectState>();

  Widget navBar() {
    return Hero(
      tag: 'iusereffect',
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromContext, toContext) {
        final heroWidget = flightDirection == HeroFlightDirection.pop
            ? fromContext.widget
            : toContext.widget;
        return ClipRect( // Isso impede overflow visual
          child: SizedBox(
            width: MediaQuery.of(flightContext).size.width,
            height: 37, // 60 de altura + 16 de padding (8 top + 8 bottom)
            child: DefaultTextStyle(
              style: Theme.of(flightContext).textTheme.labelLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              child: heroWidget,
            ),
          ),
        );
      },
      child: ClipRect( // Também no destino final
        child: IUserEffect(
          key: iuserEffectKey,
          borderSize: 3,
          child: SizedBox( // Use SizedBox ao invés de Container aqui
            height: 37,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    if (selectedIndex != index) {
                      setState(() {
                        selectedIndex = index;
                      });
                      iuserEffectKey.currentState?.accelerate();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        navItems[index]['icon'],
                        color: isSelected ? primaryColor : inactiveColor,
                        size: isSelected ? 30 : 27,
                      ),
                     /* const SizedBox(height: 4),
                      Text(
                        navItems[index]['title'],
                        style: TextStyle(
                          color: isSelected ? primaryColor : inactiveColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),*/
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = viewInsets > 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        child: Stack(
          children: [
            Expanded(child: pages[selectedIndex]),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  height: isKeyboardOpen ? 25 : 65,
                  child: Opacity(
                    opacity: isKeyboardOpen ? 0.3 : 1.0,
                    child: navBar(),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

}
