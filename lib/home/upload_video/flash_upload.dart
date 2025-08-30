
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'flash_upload_controller.dart';


class FlashUpload extends StatefulWidget {
  @override
  _FlashUploadState createState() => _FlashUploadState();
}

class _FlashUploadState extends State<FlashUpload> {
  final FlashUploadController controller = Get.put(FlashUploadController());

  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;

    controller.setVideoFile(File(pickedFile.path));

    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(controller.videoFile.value!)
      ..initialize().then((_) => setState(() {}));

    await controller.extractThumbnail(controller.videoFile.value!);
  }

  Future<void> _pickThumbnailFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) controller.setThumbnailFile(File(pickedImage.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mostrar um flash'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.videoFile.value == null)
                _buildVideoSelector()
              else ...[
                _buildThumbnailSelector(),
                SizedBox(height: 24),
                _buildInfoCard(),
                SizedBox(height: 24),
                if (_videoPlayerController?.value.isInitialized ?? false)
                  _buildVideoPreview(),
                SizedBox(height: 24),
                controller.isUploading.value
                    ? Center(child: CircularProgressIndicator())
                    : _buildUploadButton(),
                SizedBox(height: 60),
              ],
            ],
          );
        }),
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
              _videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
    return ElevatedButton(
      onPressed: controller.uploadVideo,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text("PUBLICAR VÍDEO", style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildThumbnailSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickThumbnailFromGallery,
          child: Obx(() {
            final thumb = controller.thumbnailFile.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: thumb != null
                  ? Image.file(thumb, height: 180, width: 180, fit: BoxFit.cover)
                  : Container(height: 180, width: 180, color: Colors.grey[200]),
            );
          }),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: _pickThumbnailFromGallery,
          child: Text("ALTERAR CAPA", style: TextStyle(color: Colors.blue)),
        ),
        SizedBox(height: 16),
        Obx(() {
          return SwitchListTile(
            value: controller.showOnMap.value,
            onChanged: controller.setShowOnMap,
            title: Text("Mostrar vídeo no mapa"),
            subtitle: Text("Se ativado, o vídeo será exibido no mapa com sua localização atual."),
          );
        }),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              controller: controller.titleController,
              decoration: _inputDecoration("Título"),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: controller.toggleTagField,
              child: Obx(() {
                final show = controller.showTagField.value;
                return Row(
                  children: [
                    Icon(show ? Icons.remove : Icons.add, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(show ? "REMOVER TAGS" : "ADICIONAR TAGS",
                        style: TextStyle(color: Colors.blue)),
                  ],
                );
              }),
            ),
            Obx(() => controller.showTagField.value
                ? Column(
              children: [
                SizedBox(height: 16),
                TextField(
                  controller: controller.descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration("Descrição e Tags"),
                ),
              ],
            )
                : SizedBox.shrink()),
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
