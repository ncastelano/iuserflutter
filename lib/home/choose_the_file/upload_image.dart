import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_compress/video_compress.dart';

class UploadImage extends StatefulWidget {
  final File imageFile;

  const UploadImage(this.imageFile, {Key? key}) : super(key: key);

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  late File _selectedImage;
  String searchQuery = "";
  String? selectedSong;
  int totalSongDuration = 0;
  bool isLoadingDuration = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.imageFile;
  }

  Future<int> _getVideoDuration(String url) async {
    try {
      final info = await VideoCompress.getMediaInfo(url);
      return (info.duration! / 1000).round(); // converte ms para s
    } catch (e) {
      debugPrint("Erro ao obter duração: $e");
      return 0;
    }
  }

  void _showAddSoundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Adicionar Som"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Procurar música...",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setStateDialog(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("videos")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text("Nenhum vídeo encontrado"));
                        }

                        final docs = snapshot.data!.docs;
                        final filteredDocs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                          (data["artistSongName"] ?? "").toString();
                          return name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase());
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(child: Text("Nenhum resultado"));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final data =
                            filteredDocs[index].data() as Map<String, dynamic>;
                            final thumbnailUrl = data["thumbnailUrl"] ??
                                "https://via.placeholder.com/100x100.png?text=No+Thumb";
                            final songName =
                                data["artistSongName"] ?? "Sem nome";
                            final videoUrl = data["videoUrl"] ?? "";

                            return ListTile(
                              leading: Image.network(
                                thumbnailUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(songName),
                              onTap: () async {
                                Navigator.pop(context);

                                setState(() {
                                  selectedSong = songName;
                                  totalSongDuration = 0;
                                  isLoadingDuration = true;
                                });

                                int duration = 0;
                                if (videoUrl.isNotEmpty) {
                                  duration = await _getVideoDuration(videoUrl);
                                }

                                if (!mounted) return;

                                setState(() {
                                  totalSongDuration = duration;
                                  isLoadingDuration = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Selecionou: $songName ($duration s)")),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enviar som escolhido")),
                  );
                },
                child: const Text("Enviar Som"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image - iUser')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(_selectedImage, height: 200),
            const SizedBox(height: 20),
            selectedSong == null
                ? ElevatedButton(
              onPressed: _showAddSoundDialog,
              child: const Text("Adicionar Som"),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.music_note,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Som: $selectedSong",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selectedSong = null;
                          totalSongDuration = 0;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync, color: Colors.green),
                      onPressed: _showAddSoundDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isLoadingDuration)
                  const Text(
                    "Carregando...",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  )
                else if (totalSongDuration > 0)
                  Text(
                    "Duração: $totalSongDuration segundos",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  )
                else
                  const Text(
                    "Duração não disponível",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
