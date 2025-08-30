import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/post.dart';

class FlashScreen extends StatefulWidget {
  final String? id;
  final String? image;

  const FlashScreen({
    Key? key,
    required this.id,
    required this.image,
  }) : super(key: key);

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  Post? _post;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('videos')
          .where('videoID', isEqualTo: widget.id)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        final post = Post.fromDocumentSnapshot(doc.docs.first);
        _videoController = VideoPlayerController.network(post.videoUrl ?? '')
          ..initialize().then((_) {
            setState(() {
              _post = post;
              _isLoading = false;
              _videoController!.play();
              _videoController!.setLooping(true);
            });
          });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Erro ao buscar post: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double halfHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: halfHeight,
              width: double.infinity,
              child: _isLoading
                  ? Hero(
                tag: widget.image!,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Image.network(
                    widget.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : _videoController != null && _videoController!.value.isInitialized
                  ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              )
                  : Hero(
                tag: widget.image!,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Image.network(
                    widget.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_post != null) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(_post!.userProfileImage ?? ''),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _post!.userName ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _post!.title ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _post!.descriptionTags ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 🔽 Espaço reservado para conteúdo adicional no futuro
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Conteúdo adicional aqui futuramente...',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
