import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuser/home/upload_video/select_mp3_upload.dart';
import 'package:iuser/home/upload_video/select_text_upload.dart';

class SelectVideoUpload extends StatefulWidget {
  const SelectVideoUpload({Key? key}) : super(key: key);

  @override
  _SelectVideoUploadState createState() => _SelectVideoUploadState();
}

class _SelectVideoUploadState extends State<SelectVideoUpload> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  bool _isPressed = false;

  bool _isFlashOn = false;

  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  final double borderSize = 60;
  final double buttonSize = 40;
  Offset? _initialPointerPosition;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("Nenhuma câmera encontrada");
        return;
      }
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      _minZoom = await _cameraController!.getMinZoomLevel();
      _maxZoom = await _cameraController!.getMaxZoomLevel();
      _currentZoom = _minZoom;

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Erro ao inicializar câmera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Erro ao alternar flash: $e');
    }
  }

  void _handlePointerMove(PointerMoveEvent event) async {
    if (_cameraController == null || _initialPointerPosition == null) return;

    double dy = _initialPointerPosition!.dy - event.position.dy;
    double zoomChange = dy * 0.001;

    double newZoom = (_currentZoom + zoomChange).clamp(_minZoom, _maxZoom);

    if ((newZoom - _currentZoom).abs() > 0.01) {
      _currentZoom = newZoom;
      await _cameraController!.setZoomLevel(_currentZoom);
      setState(() {});
    }
  }

  void _resetPointer() {
    _initialPointerPosition = null;
  }

  Future<void> _onVideosTap() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      print('Vídeo selecionado: ${video.path}');
    } else {
      print('Nenhum vídeo selecionado');
    }
  }

  Future<void> _onPhotosTap() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      print('Foto selecionada: ${photo.path}');
    } else {
      print('Nenhuma foto selecionada');
    }
  }

  double lerp(double min, double max, double t) => min + (max - min) * t;

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double t = (_currentZoom - _minZoom) / (_maxZoom - _minZoom);
    double borderSize = lerp(70, 100, t);
    double buttonSize = lerp(50, 30, t);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_cameraController!)),

          // Ícones no canto superior esquerdo — somem quando _isPressed = true
          Positioned(
            top: 40,
            left: 16,
            child: AnimatedOpacity(
              opacity: _isPressed ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFlash,
                    tooltip: _isFlashOn ? 'Desligar lanterna' : 'Ligar lanterna',
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Microfone à esquerda
                      AnimatedOpacity(
                        opacity: _isPressed ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.white, size: 28),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const SelectMp3Upload(),
                            ));
                          },
                          tooltip: 'Gravar áudio',
                        ),
                      ),

                      const SizedBox(width: 30),

                      // Botão animado no centro
                      Listener(
                        onPointerDown: (event) {
                          setState(() {
                            _isPressed = true;
                          });
                          _initialPointerPosition = event.position;
                        },
                        onPointerMove: (event) {
                          _handlePointerMove(event);
                        },
                        onPointerUp: (event) {
                          setState(() {
                            _isPressed = false;
                          });
                          _resetPointer();
                        },
                        onPointerCancel: (event) {
                          setState(() {
                            _isPressed = false;
                          });
                          _resetPointer();
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: borderSize,
                              height: borderSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(
                                  color: _isPressed ? Colors.red : Colors.white,
                                  width: 4,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: buttonSize,
                              height: buttonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isPressed ? Colors.red : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: _isPressed ? Colors.redAccent : Colors.white70,
                                  width: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 30),

                      // Lápis à direita com Hero
                      AnimatedOpacity(
                        opacity: _isPressed ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Hero(
                          tag: 'hero-pencil',
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 28),
                            onPressed: () {
                              // Navegar para SelectTextUpload
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const SelectTextUpload(),
                              ));
                            },
                            tooltip: 'Editar',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Textos somem quando _isPressed = true
                  AnimatedOpacity(
                    opacity: _isPressed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _onVideosTap,
                          child: const Text(
                            'Galeria de Vídeos',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 40),
                        GestureDetector(
                          onTap: _onPhotosTap,
                          child: const Text(
                            'Galeria de Fotos',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




