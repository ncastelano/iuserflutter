import 'dart:typed_data' as typed_data;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'edit_image.dart';

class FilePhoto extends StatefulWidget {
  const FilePhoto({Key? key}) : super(key: key);

  @override
  State<FilePhoto> createState() => _FilePhotoState();
}

class _FilePhotoState extends State<FilePhoto> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(cameras![0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        isReady = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      final typed_data.Uint8List bytes = await file.readAsBytes();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditImage(imageData: bytes),
        ),
      );
    } catch (e) {
      print('Erro ao tirar foto: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tirar Foto')),
      body: CameraPreview(_controller!),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: _takePicture,
      ),
    );
  }
}
