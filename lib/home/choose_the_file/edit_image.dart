import 'dart:io';
import 'dart:typed_data' as typed_data;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';
import 'package:file_picker/file_picker.dart';

class EditImage extends StatefulWidget {
  final typed_data.Uint8List imageData;

  const EditImage({required this.imageData, Key? key}) : super(key: key);

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  late img.Image _image;
  late String _fileName;
  List<Filter> filters = presetFiltersList;

  @override
  void initState() {
    super.initState();
    _image = img.decodeImage(widget.imageData)!;
    _fileName = 'temp_image.jpg';
  }

  Future<void> _openFilterDialog() async {
    final imageFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          title: const Text("Aplicar filtro"),
          image: _image,
          filters: filters,
          filename: _fileName,
          loader: const Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );

    if (imageFile != null && imageFile is Map<String, dynamic>) {
      setState(() {
        _image = imageFile['image'] as img.Image;
      });
    }
  }

  Future<void> _saveImage() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (permission != PermissionState.authorized &&
        permission != PermissionState.limited) {
      await _showPermissionDeniedDialog();
      return;
    }

    if (permission == PermissionState.limited) {
      final proceed = await _showLimitedAccessDialog();
      if (!proceed) return;
      await PhotoManager.presentLimited();
      final permissionAgain = await PhotoManager.requestPermissionExtend();
      if (permissionAgain != PermissionState.authorized &&
          permissionAgain != PermissionState.limited) {
        await _showPermissionDeniedDialog();
        return;
      }
    }

    // Perguntar nome e pasta
    final saveInfo = await _askFileNameAndFolder();
    if (saveInfo == null) return; // Usuário cancelou

    final fileName = saveInfo['name']!;
    final folderPath = saveInfo['folder']!;

    try {
      final filteredImageBytes = img.encodeJpg(_image);

      // Salvar na pasta escolhida
      final filePath = '$folderPath/$fileName.jpg';
      final file = File(filePath);
      await file.writeAsBytes(filteredImageBytes);

      // Salvar também na galeria
      final assetId = await PhotoManager.editor.saveImageWithPath(file.path);

      if (assetId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagem salva em:\n$filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao salvar imagem.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar imagem: $e')),
      );
    }
  }

  Future<Map<String, String>?> _askFileNameAndFolder() async {
    String fileName = '';
    String? folderPath;

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salvar imagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nome do arquivo (sem extensão)',
                ),
                onChanged: (value) => fileName = value,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  folderPath = await FilePicker.platform.getDirectoryPath();
                  setState(() {}); // Para atualizar o preview do caminho
                },
                icon: const Icon(Icons.folder),
                label: const Text('Escolher pasta'),
              ),
              if (folderPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    folderPath!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (fileName.trim().isEmpty || folderPath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe o nome e a pasta')),
                  );
                  return;
                }
                Navigator.pop(context, {
                  'name': fileName.trim(),
                  'folder': folderPath!,
                });
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permissão necessária'),
        content: const Text(
          'Para salvar imagens na galeria, o aplicativo precisa da sua permissão de acesso às fotos.\n'
              'Por favor, considere permitir tudo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showLimitedAccessDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Acesso limitado'),
        content: const Text(
          'Seu acesso às fotos está limitado. Para salvar a imagem, por favor permita o acesso completo.\n\n'
              'Deseja abrir as opções de permissão agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ver permissões'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _shareImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Função compartilhar ainda não implementada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredImageBytes = img.encodeJpg(_image);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Imagem'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.memory(
                typed_data.Uint8List.fromList(filteredImageBytes),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Botão Ver filtros (apenas ícone)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: _openFilterDialog,
                    child: const Icon(Icons.filter, color: Colors.black),
                  ),
                  const SizedBox(width: 8),

                  // Botão Salvar na galeria (apenas ícone)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: _saveImage,
                    child: const Icon(Icons.save_alt, color: Colors.black),
                  ),
                  const SizedBox(width: 8),

                  // Botão Compartilhar (com texto)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('Compartilhar'),
                    onPressed: _shareImage,
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
