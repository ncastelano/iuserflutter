import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iuser/home/upload_video/select_mp3_upload.dart';
import 'package:iuser/home/upload_video/select_video_upload.dart';

class SelectTextUpload extends StatelessWidget {
  const SelectTextUpload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fundo preto
          const SizedBox.expand(child: ColoredBox(color: Colors.black)),

          // Campo de texto centralizado
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 22),
                maxLines: null,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Escreva aqui...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Botões embaixo, alinhados com troca de posição do lápis e do botão animado
          Positioned(
            bottom: 130,
            left: -20,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10,0,50,0),
                        child: Hero(
                          tag: 'mic',
                          child: IconButton(
                            icon: const Icon(Icons.mic, color: Colors.white, size: 28),
                            onPressed: () {
                              // Navegar para SelectTextUpload
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const SelectMp3Upload(),
                              ));
                            },
                            tooltip: 'Gravar',
                          ),
                        ),
                      ),


                      // Lápis à direita com Hero

                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Para borda circular
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Hero(
                          tag: 'hero-pencil',
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 60),
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




                      // Botão animado no centro
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50,0,10,0),
                        child: GestureDetector(
                          onTap: () {
                            // Navegar para SelectTextUpload
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:  Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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