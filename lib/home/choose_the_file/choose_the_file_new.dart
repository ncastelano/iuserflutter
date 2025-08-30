import 'package:flutter/material.dart';
import 'package:iuser/home/choose_the_file/file_photo.dart';
import 'package:iuser/home/choose_the_file/file_video.dart';
import 'package:iuser/home/choose_the_file/photograph.dart';
import '../bottom_bar/bottom_bar.dart';
import 'edit_image.dart';
import 'edit_image_file.dart';
import 'edit_song2.dart';
import 'edit_video.dart';
import 'edit_song.dart';
import 'file_mic.dart';
import 'file_text.dart';
import 'edit_pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ChooseTheFileNew extends StatefulWidget {
  const ChooseTheFileNew({Key? key}) : super(key: key);

  @override
  State<ChooseTheFileNew> createState() => _ChooseTheFileNewState();
}

class _ChooseTheFileNewState extends State<ChooseTheFileNew> {
  int selectedIndex = 3;

  Future<void> _pickPdfAndNavigate(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditPDF(pdfFile: file)),
      );
    }
  }

  Future<void> _pickVideoAndNavigate(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditVideo(videoFile: file)),
      );
    }
  }

  Future<void> _pickImageAndNavigate(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditImageFile(imageFile: file)),
      );
    }
  }

  Future<void> _pickAudioAndNavigate(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
    );
    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditSongWave(audioFile: file)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildOption({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? iconColor,
    }) {
      return ListTile(
        leading: Icon(icon, size: 32, color: iconColor ?? Colors.white),
        title: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escolha o jeito de compartilhar'),
          backgroundColor: Colors.black,
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: selectedIndex),
        backgroundColor: Colors.black,
        body: ListView(
          children: [
            const SizedBox(height: 12),

            buildOption(
              icon: Icons.camera_alt,
              label: 'Tirar Foto',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Photograph())//FilePhoto()),
                );
              },
            ),


            buildOption(
              icon: Icons.videocam_outlined,
              label: 'Gravar Vídeo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FileVideo()),
                );
              },
            ),

            buildOption(
              icon: Icons.mic,
              label: 'Gravar Áudio',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FileMic()),
                );
              },
            ),

            buildOption(
              icon: Icons.videocam,
              label: 'Escolher Vídeo da Galeria',
              onTap: () => _pickVideoAndNavigate(context),
            ),

            buildOption(
              icon: Icons.image,
              label: 'Escolher Imagem da Galeria',
              onTap: () => _pickImageAndNavigate(context),
            ),

            buildOption(
              icon: Icons.music_note,
              label: 'Escolher Som',
              onTap: () => _pickAudioAndNavigate(context),
            ),

            buildOption(
              icon: Icons.picture_as_pdf,
              label: 'Escolher PDF',
              onTap: () => _pickPdfAndNavigate(context),
            ),

            buildOption(
              icon: Icons.edit,
              label: 'Escrever Texto',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FileText()),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
