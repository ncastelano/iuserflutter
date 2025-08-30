import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FileVideo extends StatefulWidget {
  const FileVideo({Key? key}) : super(key: key);

  @override
  State<FileVideo> createState() => _FileVideoState();
}

class _FileVideoState extends State<FileVideo> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Hero(
        tag: 'cameraPreviewHero',
        flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
          final widget = direction == HeroFlightDirection.pop
              ? fromContext.widget
              : toContext.widget;
          return DefaultTextStyle(
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            child: widget,
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: _controller == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller!);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
