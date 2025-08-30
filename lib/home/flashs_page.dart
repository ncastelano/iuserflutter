import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iuser/home/users/all_users_screen.dart';

import 'bottom_bar/bottom_bar.dart';
import 'choose_type.dart';
import 'following/list_of_following_screen.dart';
import 'following/list_of_for_you_screen.dart';
import 'mapa/mapa.dart';

class FlashsPage extends StatefulWidget {
  const FlashsPage({Key? key}) : super(key: key);

  @override
  State<FlashsPage> createState() => _FlashsPageState();
}

class _FlashsPageState extends State<FlashsPage> {

  int selectedIndex = 1;


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
      bottomNavigationBar: BottomNavBar(selectedIndex: 1,),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Seção: Mais Comentados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Mais Comentados',
              style: GoogleFonts.abel(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const ListOfForYouScreen(),

          const SizedBox(height: 24),

          // Seção: Sigo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'De quem você segue',
              style: GoogleFonts.abel(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const ListOfFollowingsScreen(),
        ],
      ),
    );
  }
}
