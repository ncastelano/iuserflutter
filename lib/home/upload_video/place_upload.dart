
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuser/home/main_page.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/post.dart';


class PlaceUpload extends StatefulWidget {
  @override
  _PlaceUploadState createState() => _PlaceUploadState();
}

class _PlaceUploadState extends State<PlaceUpload> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  File? _videoFile, _thumbnailFile;
  bool _showTagField = false;
  bool _isUploading = false;
  bool _showOnMap = false;
  double? _latitude;
  double? _longitude;
  final String _selectedPostType = 'place'; // Fixado como 'flash'

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  // Video and thumbnail handling
  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _videoFile = File(pickedFile.path));
    _videoPlayerController = VideoPlayerController.file(_videoFile!)
      ..initialize().then((_) => setState(() {}));
    _extractThumbnail(_videoFile!);
  }

  Future<void> _extractThumbnail(File videoFile) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoFile.path);
    setState(() => _thumbnailFile = thumbnail);
  }

  Future<void> _pickThumbnailFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) setState(() => _thumbnailFile = File(pickedImage.path));
  }

  // Video processing and upload
  Future<File?> _compressVideo(String videoPath) async {
    final compressed = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.LowQuality,
    );
    return compressed?.file;
  }

  Future<String> _uploadFile(File file, String path) async {
    final uploadTask = FirebaseStorage.instance.ref().child(path).putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null || _thumbnailFile == null) {
      _showSnackBar("Selecione um vídeo e preencha os campos!");
      return;
    }

    setState(() => _isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final videoID = FirebaseFirestore.instance.collection("videos").doc().id;

      final videoUrl = await _uploadFile(
        (await _compressVideo(_videoFile!.path))!,
        "All Videos/$videoID",
      );

      final thumbnailUrl = await _uploadFile(
        _thumbnailFile!,
        "All Thumbnails/$videoID",
      );

      final newVideo = Post(
        userID: user.uid,
        userName: userData["name"],
        userProfileImage: userData["image"],
        postID: videoID,
        totalComments: 0,
        likesList: [],
        title: _titleController.text.trim(),
        descriptionTags: _descriptionController.text.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        publishedDateTime: DateTime.now(),
        latitude: _latitude,
        longitude: _longitude,
        isStore: _selectedPostType == 'store',
        isFlash: _selectedPostType == 'flash',
        isProduct: _selectedPostType == 'product',
        isPlace: _selectedPostType == 'place',
      );



      await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoID)
          .set(newVideo.toJson());

      _showSnackBar("Vídeo enviado com sucesso!");
      Get.offAll(MainPage());
    } catch (e) {
      _showSnackBar("Erro ao enviar vídeo: ${e.toString()}");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black, // Fundo preto
        content: Text(
          message,
          style: TextStyle(color: Colors.white), // Texto branco
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Local'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_videoFile == null) _buildVideoSelector(),
            if (_videoFile != null) ...[
              _buildThumbnailSelector(),
              SizedBox(height: 24),
              _buildInfoCard(),
              SizedBox(height: 24),
              if (_videoPlayerController?.value.isInitialized ?? false)
                _buildVideoPreview(),
              SizedBox(height: 24),
              _buildUploadButton(),
              SizedBox(height: 60),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: VideoPlayer(_videoPlayerController!),
          ),
          IconButton(
            icon: Icon(
              _videoPlayerController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: 48,
            ),
            onPressed: () => setState(() {
              _videoPlayerController!.value.isPlaying
                  ? _videoPlayerController!.pause()
                  : _videoPlayerController!.play();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return _isUploading
        ? Center(child: CircularProgressIndicator())
        : ElevatedButton(
      onPressed: _uploadVideo,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text("PUBLICAR VÍDEO", style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildThumbnailSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickThumbnailFromGallery,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _thumbnailFile != null
                ? Image.file(_thumbnailFile!, height: 180, width: 180, fit: BoxFit.cover)
                : Container(height: 180, width: 180, color: Colors.grey[200]),
          ),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: _pickThumbnailFromGallery,
          child: Text("ALTERAR CAPA", style: TextStyle(color: Colors.blue)),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          value: _showOnMap,
          onChanged: (value) async {
            setState(() => _showOnMap = value);

            if (value) {
              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                _showSnackBar('Serviços de localização estão desativados.');
                return;
              }

              LocationPermission permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  _showSnackBar('Permissão de localização negada.');
                  return;
                }
              }

              if (permission == LocationPermission.deniedForever) {
                _showSnackBar('Permissão de localização permanentemente negada.');
                return;
              }

              final position = await Geolocator.getCurrentPosition();
              _latitude = position.latitude;
              _longitude = position.longitude;
            } else {
              _latitude = null;
              _longitude = null;
            }
          },
          title: Text("Mostrar vídeo no mapa"),
          subtitle: Text("Se ativado, o vídeo será exibido no mapa com sua localização atual."),
        ),
      ],
    );
  }

  Widget _buildVideoSelector() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: OutlinedButton.icon(
        onPressed: _pickVideo,
        icon: Icon(Icons.video_library, size: 24),
        label: Text("SELECIONAR VÍDEO", style: TextStyle(fontSize: 16)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: _inputDecoration("Título"),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _showTagField = !_showTagField),
              child: Row(
                children: [
                  Icon(_showTagField ? Icons.remove : Icons.add, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(_showTagField ? "REMOVER TAGS" : "ADICIONAR TAGS",
                      style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            if (_showTagField) ...[
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration("Descrição e Tags"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
