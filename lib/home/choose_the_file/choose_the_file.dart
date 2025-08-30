import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';
import '../bottom_bar/bottom_bar.dart';
import 'edit_pdf.dart';
import 'file_mic.dart';
import 'gallery_images.dart';
import 'gallery_songs.dart';
import 'gallery_videos.dart';
import 'dart:io';

class ChooseTheFile extends StatefulWidget {
  const ChooseTheFile({Key? key}) : super(key: key);

  @override
  State<ChooseTheFile> createState() => _ChooseTheFileState();
}

class _ChooseTheFileState extends State<ChooseTheFile> {
  int selectedIndex = 0;
  bool _loading = true;
  bool _hasPermission = false;

  CameraController? _cameraController;
  late Future<List<CameraDescription>> _futureCameras;

  // Inicializa como lista vazia para evitar erro de late
  Future<List<AssetPathEntity>> _futureVideoPaths = Future.value([]);
  Future<List<AssetPathEntity>> _futureImagePaths = Future.value([]);
  Future<List<AssetPathEntity>> _futureAudioPaths = Future.value([]);

  Future<List<AssetEntity>> _futureVideos = Future.value([]);
  Future<List<AssetEntity>> _futureImages = Future.value([]);
  Future<List<AssetEntity>> _futureAudios = Future.value([]);

  @override
  void initState() {
    super.initState();
    _initPermissionAndLoad();
  }

  Future<void> _initPermissionAndLoad() async {
    setState(() => _loading = true);

    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || ps.hasAccess) {
      _hasPermission = true;

      // Carregar listas de pastas
      _futureVideoPaths = PhotoManager.getAssetPathList(type: RequestType.video);
      _futureImagePaths = PhotoManager.getAssetPathList(type: RequestType.image);
      _futureAudioPaths = PhotoManager.getAssetPathList(type: RequestType.audio);

      // Vídeos
      final videoPaths = await _futureVideoPaths;
      _futureVideos = videoPaths.isNotEmpty
          ? videoPaths.first.getAssetListPaged(page: 0, size: 25)
          : Future.value([]);

      // Imagens
      final imagePaths = await _futureImagePaths;
      _futureImages = imagePaths.isNotEmpty
          ? imagePaths.first.getAssetListPaged(page: 0, size: 25)
          : Future.value([]);

      // Áudios
      final audioPaths = await _futureAudioPaths;
      _futureAudios = audioPaths.isNotEmpty
          ? audioPaths.first.getAssetListPaged(page: 0, size: 25)
          : Future.value([]);

      // Inicializar câmera separadamente
      try {
        _futureCameras = availableCameras();
        final cameras = await _futureCameras;
        if (cameras.isNotEmpty) {
          _cameraController =
              CameraController(cameras.first, ResolutionPreset.medium);
          await _cameraController!.initialize();
        }
      } catch (e) {
        debugPrint("Erro ao inicializar câmera: $e");
      }
    } else {
      _hasPermission = false;
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  String getLastTwoFolders(String path) {
    final parts = path.split('/');
    if (parts.length >= 2) {
      return parts.sublist(parts.length - 2).join('/');
    } else {
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              'Permissão necessária para acessar suas mídias',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await PhotoManager.presentLimited();
                await _initPermissionAndLoad();
              },
              child: const Text('Conceder acesso'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: PhotoManager.openSetting,
              child: const Text('Abrir configurações',
                  style: TextStyle(color: Colors.white70)),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Compartilhe ')),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
      ),
      body: CustomScrollView(
        slivers: [
          // Botões iniciais
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Câmera
                  GestureDetector(
                    onTap: () {
                     /* if (_cameraController != null &&
                          _cameraController!.value.isInitialized) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                //FileCamera(cameraController: _cameraController!),
                            FileImage(),

                          ),
                        );
                      }*/
                    },
                    child: Container(
                      width: 49.5, // metade de 99
                      height: 72.5, // metade de 145
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8), // metade de 16
                        border: Border.all(
                            color: Colors.white, width: 1), // metade da borda
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7), // metade de 14
                        child: SizedBox(
                          width: 50, // metade de 100
                          height: 75, // metade de 150
                          child: Hero(
                            tag: 'cameraPreviewHero',
                            flightShuttleBuilder: (context, animation, direction,
                                fromContext, toContext) {
                              final widget = direction ==
                                  HeroFlightDirection.pop
                                  ? fromContext.widget
                                  : toContext.widget;
                              return DefaultTextStyle(
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9, // metade de 18
                                ),
                                child: widget,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_cameraController != null &&
                                    _cameraController!.value.isInitialized)
                                  CameraPreview(_cameraController!)
                                else
                                  Container(color: Colors.black54),
                                Column(
                                  children: const [
                                    SizedBox(height: 20), // metade de 40
                                    Icon(Icons.camera_alt,
                                        color: Colors.white70, size: 20), // metade de 40
                                    Text('Camera',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9)), // texto menor
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Microfone
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FileMic()),
                      );
                    },
                    child: Container(
                      width: 49.5,
                      height: 72.5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Column(
                        children: [
                          SizedBox(height: 20), // metade de 40
                          Icon(Icons.mic, color: Colors.white70, size: 20),
                          Text('Microfone',
                              style:
                              TextStyle(color: Colors.white, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  // Escrever
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 49.5,
                      height: 72.5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Column(
                        children: [
                          SizedBox(height: 20), // metade de 40
                          Icon(Icons.edit, color: Colors.white70, size: 20),
                          Text('Escrever',
                              style:
                              TextStyle(color: Colors.white, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Vídeos
          SliverToBoxAdapter(
            child: FutureBuilder<List<AssetPathEntity>>(
              future: _futureVideoPaths,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                      height: 150,
                      child: Center(
                          child:
                          CircularProgressIndicator(color: Colors.white)));
                }
                final paths = snap.data!;
                if (paths.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Vídeos da galeria — Nenhuma pasta encontrada',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  );
                }
                final firstPath = paths.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Vídeos da galeria — ${firstPath.name}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    GalleryVideos(
                      title: "Vídeos",
                      futureAssets: firstPath.getAssetListPaged(page: 0, size: 25),
                      assetPath: firstPath,
                      icon: Icons.videocam,
                      iconColor: Colors.red,
                      getLastTwoFolders: getLastTwoFolders,
                    ),
                  ],
                );
              },
            ),
          ),

          // Imagens
          SliverToBoxAdapter(
            child: FutureBuilder<List<AssetPathEntity>>(
              future: _futureImagePaths,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                      height: 150,
                      child: Center(
                          child:
                          CircularProgressIndicator(color: Colors.white)));
                }
                final paths = snap.data!;
                if (paths.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Imagens da galeria — Nenhuma pasta encontrada',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  );
                }
                final firstPath = paths.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Imagens da galeria — ${firstPath.name}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    GalleryImages(
                      title: "Imagens",
                      futureAssets: firstPath.getAssetListPaged(page: 0, size: 25),
                      assetPath: firstPath,
                      icon: Icons.image,
                      iconColor: Colors.blue,
                      getLastTwoFolders: getLastTwoFolders,
                    ),
                  ],
                );
              },
            ),
          ),

          // Áudios
          SliverToBoxAdapter(
            child: FutureBuilder<List<AssetPathEntity>>(
              future: _futureAudioPaths,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                      height: 150,
                      child: Center(
                          child:
                          CircularProgressIndicator(color: Colors.white)));
                }
                final paths = snap.data!;
                if (paths.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Sons da galeria — Nenhuma pasta encontrada',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  );
                }
                final firstPath = paths.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Sons da galeria — ${firstPath.name}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    GallerySongs(
                      title: 'Sons da galeria',
                      futureAssets: firstPath.getAssetListPaged(page: 0, size: 25),
                      assetPath: firstPath,
                      icon: Icons.audiotrack,
                      iconColor: Colors.greenAccent,
                      getLastTwoFolders: getLastTwoFolders,
                    ),
                  ],
                );
              },
            ),
          ),

          // PDFs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 0, 8),
              child: Row(
                children: [
                  const Text(
                    'Pdfs da galeria',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );

                      if (result != null && result.files.isNotEmpty) {
                        File file = File(result.files.single.path!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPDF(pdfFile: file),
                          ),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Procurar PDF',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
