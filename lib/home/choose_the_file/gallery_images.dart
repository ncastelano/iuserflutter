import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'edit_image.dart';
import 'edit_image_file.dart';

class GalleryImages extends StatelessWidget {
  final String title;
  final Future<List<AssetEntity>> futureAssets;
  final AssetPathEntity assetPath;
  final IconData icon;
  final Color iconColor;
  final String Function(String) getLastTwoFolders;

  const GalleryImages({
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
    return FutureBuilder<List<AssetEntity>>(
      future: futureAssets,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 150,
            child: const Center(
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
            // adicione outras traduções que precisar
          };

          // Verifica se o nome contém alguma das chaves e retorna a tradução
          for (final key in mapaTraducao.keys) {
            if (nome.toLowerCase().contains(key.toLowerCase())) {
              return mapaTraducao[key]!;
            }
          }

          // Se não encontrar tradução, retorna o nome original
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
            // Título e nome da pasta (sem ação)
            // Título e pasta
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    traduzirPasta(getLastTwoFolders(assetPath.name)),
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 16,

                    ),
                  ),
                ],
              ),
            ),

            // Lista horizontal de imagens com clique para EditImage
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: assets.length,
                itemBuilder: (context, i) {
                  final asset = assets[i];
                  return FutureBuilder<Uint8List?>(
                    future: asset.thumbnailDataWithSize(
                      const ThumbnailSize(120, 120),
                    ),
                    builder: (context, tSnap) {
                      Widget content;
                      if (tSnap.hasData && tSnap.data != null) {
                        content = GestureDetector(
                          onTap: () async {
                            final file = await asset.file;
                            if (file != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditImageFile(imageFile: file),
                                ),
                              );
                            }
                          },
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
                      } else {
                        content = Container(
                          width: 120,
                          height: 120,
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
                      }
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: content,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
