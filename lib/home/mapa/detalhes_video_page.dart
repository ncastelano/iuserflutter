import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_player/video_player.dart';  // Importando a biblioteca para o player de vídeo

import '../../models/post.dart';
import '../comments/comments_screen.dart';

class DetalhesVideoPage extends StatefulWidget {
  final Post post;
  final String? thumbnailUrl;

  const DetalhesVideoPage({
    Key? key,
    required this.post,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<DetalhesVideoPage> createState() => _DetalhesVideoPageState();
}

class _DetalhesVideoPageState extends State<DetalhesVideoPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;  // Controla a inicialização do vídeo
  bool _isExiting = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.post.videoUrl ?? '')
      ..initialize().then((_) {
        if (!_isExiting) { // Só inicializa se não estiver saindo
          setState(() {
            _isVideoInitialized = true;
          });
          _controller.play();
        }
      });
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose();  // Libera os recursos do vídeo quando a página for descartada
  }

  likeOrUnlikeVideo(String videoID) async {
    var currentUserID = FirebaseAuth.instance.currentUser!.uid.toString();

    DocumentSnapshot snapshotDoc = await FirebaseFirestore.instance
        .collection("videos")
        .doc(videoID)
        .get();

    // Verifica se já foi dado like
    if ((snapshotDoc.data() as dynamic)["likesList"].contains(currentUserID)) {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likesList": FieldValue.arrayRemove([currentUserID]),
      });
    } else {
      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .update({
        "likesList": FieldValue.arrayUnion([currentUserID]),
      });
    }
  }

  Future<void> _handleBack() async {
    setState(() {
      _isVideoInitialized = false; // Força mostrar o Hero
      _isExiting = true; // Indica que estamos saindo

    });

    if (_controller.value.isPlaying) {
      await _controller.pause();
    }
    Navigator.of(context).pop();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title ?? 'Detalhes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
      ),
      body: Column(
        children: [
          // Usando Stack para manter ambos os widgets
          Stack(
            children: [
              // Hero sempre presente (necessário para a animação)
              Hero(
                tag: widget.thumbnailUrl ?? '',
                child: Image.network(
                  height: 300,
                  width: double.infinity,
                  widget.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
              // Vídeo sobreposto quando inicializado e não está saindo
              if (_isVideoInitialized && !_isExiting)
                Container(
                  height: 300,
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
            ],
          ),
          // Usando o StreamBuilder para ouvir mudanças em likesList
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('videos')
                .doc(widget.post.postID)
                .snapshots(), // Listener em tempo real
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Exibe um carregando enquanto aguarda dados
              }

              if (!snapshot.hasData) {
                return Text('Erro ao carregar dados.');
              }

              var data = snapshot.data!.data() as Map<String, dynamic>;
              List likesList = data['likesList'] ?? [];
              int totalLikes = likesList.length;

              return Row(
                children: [
                  // Like
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          likeOrUnlikeVideo(widget.post.postID ?? '');
                        },
                        icon: Icon(
                          Icons.favorite,
                          size: 30,
                          color: likesList.contains(FirebaseAuth.instance.currentUser!.uid)
                              ? Colors.red
                              : Colors.white,
                        ),
                      ),
                      Text(
                        totalLikes.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(width: 20),

          // Usando o StreamBuilder para ouvir mudanças nos comentários
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('videos')
                .doc(widget.post.postID)
                .snapshots(), // Listener em tempo real
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Exibe um carregando enquanto aguarda dados
              }

              if (!snapshot.hasData) {
                return Text('Erro ao carregar dados.');
              }

              var data = snapshot.data!.data() as Map<String, dynamic>;
              int totalComments = data['totalComments'] ?? 0;

              return Row(
                children: [
                  // Comment
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.to(() => CommentsScreen(videoID: widget.post.postID ?? ''));
                        },
                        icon: const Icon(Icons.comment, size: 28, color: Colors.white),
                      ),
                      Text(
                        totalComments.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
