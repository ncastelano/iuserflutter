import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iuser/home/choose_the_file/choose_the_file.dart';
import 'package:iuser/home/choose_the_file/choose_the_file_new.dart';
import 'package:iuser/home/for_you/for_you_video_screen.dart';
import 'package:iuser/home/personal_card/personal_card.dart';
import 'package:iuser/home/questionnaire/questionnaire.dart';
import 'package:iuser/home/search/search_screen.dart';

import '../choose_type.dart';
import '../flashs_page.dart';
import '../mapa/mapa.dart';
import '../users/all_users_screen.dart';
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  // Lista fixa de páginas dentro do widget
  List<Widget> get pages =>  [
    Mapa(),
   SearchScreen(),
    PersonalCard(uid:FirebaseAuth.instance.currentUser!.uid),
    //ChooseType(),
    ChooseTheFileNew(),
  ];

  final List<Map<String, dynamic>> navItems = const [
    {'title': 'Mapa', 'icon': Icons.location_on},
    {'title': 'Flash', 'icon': Icons.web_stories},
    {'title': 'Pessoas', 'icon': Icons.people},
    {'title': 'Upload', 'icon': Icons.add},
  ];

  final Color backgroundColor = Colors.black;
  final Color activeColor = Colors.white;
  final Color inactiveColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () {
                if (isSelected) return;

                final bool toRight = index > selectedIndex;
                _navigateWithSlideTransition(
                  context: context,
                  page: pages[index],
                  toRight: toRight,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    navItems[index]['icon'],
                    size: isSelected ? 28 : 24,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    navItems[index]['title'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? activeColor : inactiveColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void _navigateWithSlideTransition({
    required BuildContext context,
    required Widget page,
    required bool toRight,
  }) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final beginOffset = Offset(toRight ? 1 : -1, 0);
          final tween = Tween(begin: beginOffset, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
