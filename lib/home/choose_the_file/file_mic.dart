import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class FileMic extends StatefulWidget {
  const FileMic({Key? key}) : super(key: key);

  @override
  State<FileMic> createState() => _FileMicState();
}

class _FileMicState extends State<FileMic> {
  final _record = AudioRecorder();
  final _player = AudioPlayer();
  int? _fileSizeInBytes;
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isEditingName = false;
  late TextEditingController _nameController;


  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();  // <== Inicialize aqui

    _player.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }


  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _record.start(
      const RecordConfig(),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _audioPath = null; // Oculta controles enquanto grava
      _duration = Duration.zero;
      _position = Duration.zero;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();

    setState(() {
      _isRecording = false;
      _audioPath = path;
      _duration = Duration.zero;
      _position = Duration.zero;
      _fileSizeInBytes = null;
    });

    if (_audioPath != null) {
      await _player.setSource(DeviceFileSource(_audioPath!));
      final Duration? d = await _player.getDuration();
      if (d != null) {
        final file = File(_audioPath!);
        final bytes = file.existsSync() ? file.lengthSync() : 0;
        setState(() {
          _duration = d;
          _fileSizeInBytes = bytes;
        });
      }
    }
  }


  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    await _player.play(DeviceFileSource(_audioPath!));
    setState(() => _isPlaying = true);
  }

  Future<void> _pauseAudio() async {
    await _player.pause();
    setState(() => _isPlaying = false);
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  String _fileSize() {
    if (_audioPath == null) return '';
    final file = File(_audioPath!);
    if (!file.existsSync()) return '';
    final bytes = file.lengthSync();
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  void _confirmRename() {
    setState(() {
      final oldPath = _audioPath!;
      final dir = oldPath.substring(0, oldPath.lastIndexOf('/'));
      final extension = oldPath.substring(oldPath.lastIndexOf('.'));
      final newName = _nameController.text.trim();

      if (newName.isNotEmpty) {
        _audioPath = '$dir/$newName$extension';
      }
      _isEditingName = false;
    });
  }


  String _extractFileNameWithoutExtension(String path) {
    final filename = path.split('/').last;
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1) return filename;
    return filename.substring(0, lastDot);
  }


  void _updateNameController() {
    if (_audioPath != null) {
      _nameController.text = _extractFileNameWithoutExtension(_audioPath!);
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Gravador de Áudio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      _isRecording ? Icons.stop_circle : Icons.mic,
                      size: 28,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isRecording ? 'Parar Gravação' : 'Iniciar Gravação',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.redAccent.shade700 : Colors.greenAccent.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black45,
                    ),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Controles do áudio aparecem com fade suave só se _audioPath != null
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _audioPath != null
                  ? Column(
                key: const ValueKey('audio_controls'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _isEditingName
                          ? Expanded(
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onSubmitted: (_) => _confirmRename(),
                        ),
                      )
                          : Expanded(
                        child: Text(
                          'Arquivo: ${_extractFileNameWithoutExtension(_audioPath!)}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isEditingName
                          ? IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.greenAccent,
                        ),
                        onPressed: _confirmRename,
                      )
                          : IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingName = true;
                            _updateNameController();
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                      _fileSizeInBytes != null
                          ? 'Tamanho: ${( _fileSizeInBytes! / 1024).toStringAsFixed(1)} KB'
                          : '',
                      style: const TextStyle(color: Colors.white, fontSize: 12)
                  ),

                  const SizedBox(height: 20),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blueAccent.shade400,
                      inactiveTrackColor: Colors.white24,
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                      thumbColor: Colors.blueAccent.shade700,
                      overlayColor: Colors.blueAccent.withAlpha(32),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                      valueIndicatorColor: Colors.blueAccent.shade700,
                      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                    ),
                    child: Slider(
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                      onChanged: (value) {
                        final pos = Duration(seconds: value.toInt());
                        _player.seek(pos);
                      },
                      label: _formatTime(_position),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatTime(_position),
                          style: const TextStyle(color: Colors.white)),
                      Text(_formatTime(_duration),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: _isPlaying ? _pauseAudio : _playAudio,
                      ),
                    ],
                  ),
                ],
              )
                  : SizedBox(
                key: const ValueKey('empty_space'),
                height: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
