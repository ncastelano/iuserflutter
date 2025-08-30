import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../profile/video_player_profile.dart';

class ListAndMapa extends StatelessWidget {
  final List<Map<String, dynamic>> videoList;

  const ListAndMapa({super.key, required this.videoList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Todos os Vídeos'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: videoList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 9 / 16,
        ),
        itemBuilder: (context, index) {
          final video = videoList[index];
          final videoID = video["videoID"] ?? video["id"] ?? "thumb_$index";
          final thumbnailUrl = video["thumbnailUrl"] ?? '';

          return GestureDetector(
            onTap: () {
              Get.to(
                    () => VideoPlayerProfile(
                  videoList: videoList,
                  startIndex: index,
                ),
              );
            },
            child: Hero(
              tag: 'thumb_$videoID',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(thumbnailUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
