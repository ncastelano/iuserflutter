import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iuser/home/choose_the_file/upload_image.dart';

class Photograph extends StatefulWidget {
  const Photograph({super.key});

  @override
  State<Photograph> createState() => _PhotographState();
}

class _PhotographState extends State<Photograph> {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0; // 0 = traseira, 1 = frontal
  FlashMode currentFlashMode = FlashMode.off;

  bool isTakingPhoto = false;

  // Para animação do botão de captura
  double outerSize = 50;
  double innerSize = 20;

  // Para zoom
  double currentZoom = 1.0;
  double minZoom = 1.0;
  double maxZoom = 1.0;

  // Temporizador
  int timerSeconds = 0;
  final List<int> timerOptions = [0, 3, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> initializeController() async {
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras![selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController!.initialize();

    // Obter níveis de zoom
    minZoom = await cameraController!.getMinZoomLevel();
    maxZoom = await cameraController!.getMaxZoomLevel();
    currentZoom = 1.0;

    await cameraController!.setFlashMode(currentFlashMode);

    setState(() {});
  }

  Future<void> takePhoto() async {
    if (isTakingPhoto || cameraController == null || !cameraController!.value.isInitialized) return;
    setState(() => isTakingPhoto = true);

    try {
      if (timerSeconds > 0) {
        await Future.delayed(Duration(seconds: timerSeconds));
      }

      final file = await cameraController!.takePicture();
      debugPrint("Foto tirada: ${file.path}");

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadImage(File(file.path))),
      );
    } catch (e) {
      debugPrint("Erro ao tirar foto: $e");
    }

    setState(() => isTakingPhoto = false);
  }

  Future<void> flipCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    await cameraController?.dispose();

    cameraController = CameraController(
      cameras![selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController!.initialize();
    setState(() {});
  }

  Future<void> toggleFlash() async {
    if (cameraController == null) return;

    currentFlashMode = currentFlashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await cameraController!.setFlashMode(currentFlashMode);
    setState(() {});
  }

  // Botão animado de captura
  Widget buildShutterButton() {
    return GestureDetector(
      onTap: takePhoto,
      onVerticalDragUpdate: (details) async {
        if (cameraController == null || !cameraController!.value.isInitialized) return;

        // Zoom: arrastar para cima aumenta, para baixo diminui
        currentZoom += -details.delta.dy * 0.02; // ajuste sensibilidade
        currentZoom = currentZoom.clamp(minZoom, maxZoom);

        await cameraController!.setZoomLevel(currentZoom);

        setState(() {
          outerSize = (50 + (currentZoom - 1) * 4).clamp(50, 90);
          innerSize = (20 + (currentZoom - 1) * 3).clamp(20, 60);
        });

      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          color: Colors.transparent,
        ),
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtons() {
    return SizedBox(
      height: 200, // altura fixa para o row
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Botão esquerdo (flip + temporizador)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: flipCamera,
              icon: const Icon(Icons.flip_camera_ios_outlined, size: 34, color: Colors.white),
            ),
          ),

          // Botão central (shutter)
          Column(
            children: [


              PopupMenuButton<int>(
                initialValue: timerSeconds,
                onSelected: (value) {
                  setState(() => timerSeconds = value);
                },
                itemBuilder: (context) => timerOptions
                    .map((sec) => PopupMenuItem<int>(
                  value: sec,
                  child: Text("$sec s"),
                ))
                    .toList(),
                child: Text(
                  "$timerSeconds"+" s",
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              const SizedBox(height: 20),
              buildShutterButton(),
            ],
          ),

          // Botão direito (flash)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: toggleFlash,
              icon: Icon(
                currentFlashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                size: 34,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget buildCameraPreview() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onVerticalDragUpdate: (details) async {
        if (cameraController == null) return;

        currentZoom += -details.delta.dy * 0.02; // sensibilidade
        currentZoom = currentZoom.clamp(minZoom, maxZoom);

        await cameraController!.setZoomLevel(currentZoom);

        setState(() {
          outerSize = 70 + (currentZoom - 1) * 10;
          innerSize = 50 + (currentZoom - 1) * 8;
        });
      },
      child: CameraPreview(cameraController!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: buildCameraPreview()),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: buildButtons(),
          ),
        ],
      ),
    );
  }
}
