import 'package:flutter/material.dart';

class ProfileFlashList extends StatelessWidget {
  final List<Map<String, dynamic>> videos;

  const ProfileFlashList({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    final flashVideos = videos.where((video) => video['isFlash'] == true).toList();

    if (flashVideos.isEmpty) {
      return const Text(
        'Nenhum vídeo disponível',
        style: TextStyle(color: Colors.white),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Flash',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: flashVideos.length,
            itemBuilder: (context, index) {
              final video = flashVideos[index];
              final thumbnailUrl = video['thumbnailUrl'] ?? 'https://via.placeholder.com/150';
              final artistSongName = video['artistSongName'];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        thumbnailUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 120,
                      child: Text(
                        artistSongName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
