import 'package:flutter/material.dart';
import 'package:iuser/home/upload_video/select_text_upload.dart';
import 'package:iuser/home/upload_video/select_video_upload.dart';

class SelectMp3Upload extends StatefulWidget {
  const SelectMp3Upload({Key? key}) : super(key: key);

  @override
  State<SelectMp3Upload> createState() => _SelectMp3UploadState();
}

class _SelectMp3UploadState extends State<SelectMp3Upload>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador para animação infinita de sobe e desce
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Velocidade da animação
    )..repeat(reverse: true);

    _offsetAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchMp3Pressed() {
    print('Botão Procurar MP3 pressionado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const SizedBox.expand(child: ColoredBox(color: Colors.black)),

          // Botão Procurar MP3
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _onSearchMp3Pressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Procurar MP3',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),

                const SizedBox(height: 70),
                // Texto + setinha animada
                Text(
                  "ou grave o som",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),

                const SizedBox(height: 10),


                AnimatedBuilder(
                  animation: _offsetAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _offsetAnimation.value),
                      child: Column(
                        children: const [

                          Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: 35,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Botões inferiores
          Positioned(
            bottom: 130,
            left: -20,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lápis
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 50, 0),
                    child: Hero(
                      tag: 'hero-pencil',
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SelectTextUpload(),
                          ));
                        },
                        tooltip: 'Editar',
                      ),
                    ),
                  ),

                  // Microfone com borda
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Hero(
                      tag: 'mic',
                      child: IconButton(
                        icon: const Icon(Icons.mic, color: Colors.white, size: 60),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SelectMp3Upload(),
                          ));
                        },
                        tooltip: 'Gravar',
                      ),
                    ),
                  ),

                  // Botão animado (vídeo)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 0, 10, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SelectVideoUpload(),
                        ));
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ],
                      ),
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
