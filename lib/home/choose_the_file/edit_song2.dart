import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class EditSongWave extends StatefulWidget {
  final File audioFile;
  const EditSongWave({super.key, required this.audioFile});

  @override
  State<EditSongWave> createState() => _EditSongWaveState();
}

class _EditSongWaveState extends State<EditSongWave> {
  final player = AudioPlayer();
  final waveformController = PlayerController();

  Duration? duration;
  double start = 0, end = 0;
  bool isPlaying = false;
  bool isCutting = false;

  final double waveformScale = 0.3; // Altura do waveform (compacto)
  final double lineHeight = 200;    // Altura total das linhas e círculos

  @override
  void initState() {
    super.initState();
    initAudio();

    // 🔥 Escuta o estado do player e mantém sincronizado
    player.playingStream.listen((playing) {
      if (mounted) {
        setState(() => isPlaying = playing);
      }
    });
  }

  Future<void> initAudio() async {
    await player.setFilePath(widget.audioFile.path);
    duration = player.duration;
    if (duration != null) end = duration!.inSeconds.toDouble();

    await waveformController.preparePlayer(path: widget.audioFile.path);
    setState(() {});
  }

  Future<void> cutAudio() async {
    if (duration == null) return;
    setState(() => isCutting = true);

    final dir = await getTemporaryDirectory();
    final output = File("${dir.path}/cut_${DateTime.now().millisecondsSinceEpoch}.mp3");

    final cmd = "-i \"${widget.audioFile.path}\" -ss $start -to $end -c copy \"${output.path}\"";

    await FFmpegKit.execute(cmd);

    if (output.existsSync() && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Salvo em ${output.path}")),
      );
      Navigator.pop(context, output);
    }
    setState(() => isCutting = false);
  }

  void togglePlay() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.seek(Duration(seconds: start.toInt()));
      await player.play();
    }
    // ❌ não precisa mais dar setState aqui, já é feito pelo listener
  }

  @override
  void dispose() {
    player.dispose();
    waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (duration == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Wave Tela Inteira")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double waveformWidth = constraints.maxWidth;
                    double startPos = (start / (duration?.inSeconds ?? 1)) * waveformWidth;
                    double endPos = (end / (duration?.inSeconds ?? 1)) * waveformWidth;

                    return StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, snapshot) {
                        double playedSeconds = snapshot.data?.inSeconds.toDouble() ?? 0;
                        if (playedSeconds < start) playedSeconds = start;
                        if (playedSeconds > end) playedSeconds = end;
                        double playedWidth = ((playedSeconds - start) / (end - start)) * (endPos - startPos);

                        return Stack(
                          children: [
                            // Waveform compacto
                            Positioned(
                              top: 70, // Centraliza o waveform verticalmente
                              child: AudioFileWaveforms(
                                size: Size(waveformWidth, lineHeight * waveformScale),
                                playerController: waveformController,
                                waveformType: WaveformType.fitWidth,
                                enableSeekGesture: true,
                                playerWaveStyle: const PlayerWaveStyle(
                                  fixedWaveColor: Colors.grey,
                                  liveWaveColor: Colors.grey,
                                  showSeekLine: true,
                                ),
                              ),
                            ),

                            // Faixa azul entre start e end (mesma altura do waveform)
                            Positioned(
                              left: startPos,
                              top: 70,
                              width: endPos - startPos,
                              height: lineHeight * waveformScale,
                              child: Container(
                                color: Colors.blue.withOpacity(0.2),
                              ),
                            ),



                            // Linha vermelha principal (start) - ACIMA do waveform
                            Positioned(
                              left: startPos,
                              top: 0,
                              bottom: 70, // Deixa apenas a parte superior
                              child: Container(
                                width: 4,
                                color: Colors.red,
                              ),
                            ),
                            // Círculo vermelho (start) interativo - ACIMA do waveform
                            Positioned(
                              left: startPos - -13,
                              top: 0, // Posiciona acima do waveform
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    double dx = startPos + details.delta.dx;
                                    dx = dx.clamp(0, waveformWidth);
                                    start = (dx / waveformWidth) * (duration?.inSeconds ?? 0);
                                    if (start > end) start = end;
                                  });
                                },
                                child: Container(
                                    width: 70,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,

                                    ),
                                    child: Text('${start.toStringAsFixed(2)}', style: TextStyle(color: Colors.white,fontSize: 10), )
                                ),
                              ),
                            ),

                            // Linha verde principal (end) - ABAIXO do waveform
                            Positioned(
                              left: endPos - 2,
                              top: 70,
                              bottom: 0,
                              child: Container(
                                width: 4,
                                color: Colors.green,
                              ),
                            ),
                            // Círculo verde (end) interativo - ABAIXO do waveform
                            Positioned(
                              left: endPos - 50,
                              bottom: 0, // Posiciona abaixo do waveform
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    double dx = endPos + details.delta.dx;
                                    dx = dx.clamp(0, waveformWidth);
                                    end = (dx / waveformWidth) * (duration?.inSeconds ?? 0);
                                    if (end < start) end = start;
                                  });
                                },
                                child: Container(
                                    width: 70,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,

                                    ),child: Text('${end.toStringAsFixed(2)}', style: TextStyle(color: Colors.white,fontSize: 10), )),
                              ),
                            ),




                            // Linha amarela (progresso) com altura total
                            Positioned(
                              left: playedWidth,
                              top: 70,
                              bottom: 70,
                              child: Container(
                                width: 2,
                                height: lineHeight,
                                color: Colors.yellow,
                              ),
                            ),

                            Positioned(

                              top: 70,
                              bottom: 70,
                              child: Container(
                                width: 2,
                                height: lineHeight,
                                color: Colors.yellow,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),


          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: togglePlay,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isPlaying ? "Pause" : "Play"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: isCutting ? null : cutAudio,
                icon: isCutting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.save),
                label: const Text("Salvar Corte"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}