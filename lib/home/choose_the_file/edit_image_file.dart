import 'dart:io';
import 'package:flutter/material.dart';

class EditImageFile extends StatelessWidget {
  final File imageFile;

  const EditImageFile({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Editar Imagem",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            onPressed: () {
              // Aqui você pode salvar a imagem editada ou retornar pro fluxo
              Navigator.pop(context, imageFile);
            },
          )
        ],
      ),
      body: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _editButton(Icons.crop, "Cortar", () {
              // Implementar corte
            }),
            _editButton(Icons.brush, "Desenhar", () {
              // Implementar desenho
            }),
            _editButton(Icons.filter, "Filtro", () {
              // Implementar filtro
            }),
          ],
        ),
      ),
    );
  }

  Widget _editButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        )
      ],
    );
  }
}
