import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class BuildMediaImage extends StatefulWidget {
  const BuildMediaImage({Key? key}) : super(key: key);

  @override
  State<BuildMediaImage> createState() => _BuildMediaImageState();
}

class _BuildMediaImageState extends State<BuildMediaImage> with AutomaticKeepAliveClientMixin {
  late Future<List<AssetEntity>> _futureImages;
  late Future<List<CameraDescription>> _futureCameras;
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _futureImages = _loadAllAssetsOfType(RequestType.image);
    _futureCameras = availableCameras();
  }

  Future<List<AssetEntity>> _loadAllAssetsOfType(RequestType type, {int pageSize = 1000}) async {
    final paths = await PhotoManager.getAssetPathList(onlyAll: true, type: type);
    if (paths.isEmpty) return [];
    final AssetPathEntity all = paths.first;
    final assets = await all.getAssetListPaged(page: 0, size: pageSize);
    return assets;
  }

  Future<CameraController> _initCamera(CameraDescription camera) async {
    final controller = CameraController(camera, ResolutionPreset.medium);
    await controller.initialize();
    return controller;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // importante para AutomaticKeepAliveClientMixin
    return FutureBuilder<List<AssetEntity>>(
      future: _futureImages,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final assets = snap.data ?? [];

        return FutureBuilder<List<CameraDescription>>(
          future: _futureCameras,
          builder: (context, camSnap) {
            if (!camSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final firstCamera = camSnap.data!.first;

            return FutureBuilder<CameraController>(
              future: _cameraController != null
                  ? Future.value(_cameraController)
                  : _initCamera(firstCamera).then((controller) {
                _cameraController = controller;
                return controller;
              }),
              builder: (context, ctrlSnap) {
                if (!ctrlSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final controller = ctrlSnap.data!;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: CameraPreview(controller),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 120,
                      child: Container(
                        color: Colors.black45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: assets.length,
                          itemBuilder: (context, i) {
                            final asset = assets[i];
                            return FutureBuilder<Uint8List?>(
                              future: asset.thumbnailDataWithSize(const ThumbnailSize(96, 96)),
                              builder: (context, tSnap) {
                                if (tSnap.hasData && tSnap.data != null) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        tSnap.data!,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  width: 96,
                                  height: 96,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
