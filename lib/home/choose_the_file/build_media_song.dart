import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class BuildMediaSong extends StatefulWidget {
  const BuildMediaSong({Key? key}) : super(key: key);

  @override
  State<BuildMediaSong> createState() => _BuildMediaSongState();
}

class _BuildMediaSongState extends State<BuildMediaSong> {
  late Future<List<AssetEntity>> _futureAudios;

  @override
  void initState() {
    super.initState();
    _futureAudios = _loadAllAssetsOfType(RequestType.audio);
  }

  Future<List<AssetEntity>> _loadAllAssetsOfType(RequestType type, {int pageSize = 1000}) async {
    final paths = await PhotoManager.getAssetPathList(onlyAll: true, type: type);
    if (paths.isEmpty) return [];
    final AssetPathEntity all = paths.first;
    final assets = await all.getAssetListPaged(page: 0, size: pageSize);
    return assets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetEntity>>(
      future: _futureAudios,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final assets = snap.data ?? [];

        return Container(
          color: Colors.black,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    // Implemente a gravação de áudio aqui usando pacotes como `record`
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text("Gravar áudio"),
                ),
              ),
              const Divider(color: Colors.white38),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: assets.length,
                  itemBuilder: (context, i) {
                    final asset = assets[i];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FutureBuilder<String>(
                        future: asset.titleAsync,
                        builder: (context, titleSnap) {
                          final name = titleSnap.data ?? "Áudio ${i + 1}";
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_note, color: Colors.white, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
