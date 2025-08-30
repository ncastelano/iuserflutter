
import 'package:flutter/material.dart';
import 'package:iuser/home/following/followings_video_screen.dart';
import 'package:iuser/home/for_you/for_you_video_screen.dart';
import 'package:iuser/home/search/search_screen.dart';
import 'package:iuser/home/upload_video/upload_custom_icon.dart';
import 'package:iuser/home/users/all_users_screen.dart';
import '../upload/upload_video_page.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen>
{
  int screenIndex = 0;
  List screensList =
  [
    ForYouVideoScreen(),
    //MySearchScreen(),
    SearchScreen(),
    UploadVideoPage(),
    //UploadVideoScreen(),
    FollowingsVideoScreen(),
    //ProfileScreen(visitUserID: FirebaseAuth.instance.currentUser!.uid.toString(),),
    //ListProfile(),
    //ListAllProfile(),

    //BusinessPage(),
    //UsersScreen(),
    AllUserScreen(),
  ];

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(

        onTap: (index)
        {
          setState(() {
            screenIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.purple.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: screenIndex,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30,),
            label: "Home"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30,),
              label: "Discover"
          ),

          BottomNavigationBarItem(
              icon: UploadCustomIcon(),
              label: ""
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.inbox_sharp, size: 30,),
              label: "Sigo"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard, size: 30),
              label: "Ranking"
          ),
        ],
      ),
      body: screensList[screenIndex],
    );
  }
}
