import 'package:flutter/material.dart';

import '../../widgets/custom_video_player.dart';

class VideosPage extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final int initialIndex; // Adicione este parâmetro

  const VideosPage({
    Key? key,
    required this.videos,
    this.initialIndex = 0, // Valor padrão 0 se não for fornecido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: videos.isEmpty
          ? Center(child: Text("Nenhum vídeo encontrado"))
          : PageView.builder(
        controller: PageController(initialPage: initialIndex), // Define o índice inicial
        itemCount: videos.length,
        itemBuilder: (context, index) {
          var video = videos[index];
          return Hero(
            tag: 'video-thumbnail-${video["videoID"]}',
            child: CustomVideoPlayer(
              videoUrl: video["videoUrl"],
            ),
          );
        },
      ),
    );
  }
}