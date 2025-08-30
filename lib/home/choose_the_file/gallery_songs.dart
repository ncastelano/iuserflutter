import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'edit_song.dart';  // Importe sua página EditSong

class GallerySongs extends StatelessWidget {
  final String title;
  final Future<List<AssetEntity>> futureAssets;
  final AssetPathEntity assetPath;
  final IconData icon;
  final Color iconColor;
  final String Function(String) getLastTwoFolders;

  const GallerySongs({
    Key? key,
    required this.title,
    required this.futureAssets,
    required this.assetPath,
    required this.icon,
    required this.iconColor,
    required this.getLastTwoFolders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        FutureBuilder<List<AssetEntity>>(
          future: futureAssets,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }
            String traduzirPasta(String nome) {
              final mapaTraducao = {
                'Camera': 'Câmera',
                'Pictures': 'Imagens',
                'Downloads': 'Downloads', // pode deixar igual
                'Music': 'Música',
                'Videos': 'Vídeos',
                'Documents': 'Documentos',
                'recent': 'Recentes'
                // adicione outras traduções necessárias
              };

              // Tenta encontrar uma tradução que contenha a palavra
              for (final key in mapaTraducao.keys) {
                if (nome.toLowerCase().contains(key.toLowerCase())) {
                  return nome.replaceAll(RegExp(key, caseSensitive: false), mapaTraducao[key]!);
                }
              }

              // Se não encontrar, retorna o nome original
              return nome;
            }

            final assets = snap.data ?? [];

            if (assets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  'Nenhum $title encontrado',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: assets.length,
                    itemBuilder: (context, i) {
                      final asset = assets[i];

                      if (asset.type == AssetType.audio) {
                        return GestureDetector(
                          onTap: () async {
                            final file = await asset.file;
                            if (file != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditSong(audioFile: file),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.audiotrack,
                                    color: iconColor.withOpacity(0.7),
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  asset.title ?? 'Áudio',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Para outros tipos, mostra ícone genérico
                      return FutureBuilder<Uint8List?>(
                        future: asset.thumbnailDataWithSize(
                          const ThumbnailSize(120, 120),
                        ),
                        builder: (context, tSnap) {
                          if (tSnap.hasData && tSnap.data != null) {
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  tSnap.data!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: iconColor.withOpacity(0.7),
                              size: 48,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
