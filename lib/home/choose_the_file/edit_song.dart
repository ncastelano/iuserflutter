import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/publication.dart';
import 'geohash_helper.dart';

class EditSong extends StatefulWidget {
  final File audioFile;

  const EditSong({Key? key, required this.audioFile}) : super(key: key);

  @override
  State<EditSong> createState() => _EditSongState();
}

class _EditSongState extends State<EditSong> {
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isUploading = false;
  bool _isLoadingLocation = true;
  bool _visibleOnMap = true;
  bool _acceptedTerms = false;
  bool _editarData = false;
  String? _selectedCategory;

  final _nameController = TextEditingController();
  final _hashtagController = TextEditingController();
  final _priceController = TextEditingController();
  final _createdDateController = TextEditingController(); // <-- controller para createdDateTime
  final String dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

  GeoPoint? position;
  String? geohash;

  File? _selectedImage;

  List<String> hashtags = [];
  final int maxHashtags = 3;

  final List<String> _categories = [
    "Música",
    "Podcast",
    "Audiobook",
    "Áudio"
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
    _getUserLocation();

    // Inicializa createdDateController com a data atual
    final now = DateTime.now();
    _createdDateController.text = DateFormat('dd-MM-yyyy').format(now);
  }

  Future<void> _initAudio() async {
    try {
      await _player.setFilePath(widget.audioFile.path);
      _duration = _player.duration ?? Duration.zero;

      _player.positionStream.listen((pos) {
        setState(() => _position = pos);
      });

      _player.playerStateStream.listen((state) {
        setState(() => _isPlaying = state.playing);
      });
    } catch (e) {
      debugPrint('Erro ao carregar áudio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar áudio: $e")),
      );
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Serviço de localização desativado.")),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permissão de localização negada.")),
          );
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permissão de localização negada permanentemente.")),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        position = GeoPoint(pos.latitude, pos.longitude);
        geohash = GeoHashHelper.encode(pos.latitude, pos.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      debugPrint("Erro ao obter localização: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao obter localização: $e")),
      );
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _nameController.dispose();
    _hashtagController.dispose();
    _priceController.dispose();
    _createdDateController.dispose(); // <-- dispose do controller
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao selecionar imagem: $e")),
      );
    }
  }

  Future<void> _savePublication() async {
    if (_isLoadingLocation || position == null || geohash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aguardando localização...")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final storageRefAudio = FirebaseStorage.instance
          .ref()
          .child('songs/${DateTime.now().millisecondsSinceEpoch}.mp3');
      await storageRefAudio.putFile(widget.audioFile);
      final songUrl = await storageRefAudio.getDownloadURL();

      String? imageUrl;
      if (_selectedImage != null) {
        final storageRefImage = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRefImage.putFile(_selectedImage!);
        imageUrl = await storageRefImage.getDownloadURL();
      }

      final docRef = FirebaseFirestore.instance.collection('publications').doc();
      final now = DateTime.now();

      // 🔹 publishedDateTime sempre é agora
      final publishedDate = now;

      // 🔹 createdDateTime depende do switch
      DateTime createdDate;
      if (_editarData && _createdDateController.text.isNotEmpty) {
        try {
          createdDate = DateFormat('dd-MM-yyyy').parse(_createdDateController.text);
        } catch (_) {
          createdDate = publishedDate; // fallback
        }
      } else {
        createdDate = publishedDate; // se não editar, usa publishedDate
      }

      final publication = Publication(
        position: position!,
        geohash: geohash!,
        ranking: 0,
        publicationType: "song",
        ownerType: "user",
        userID: FirebaseAuth.instance.currentUser!.uid,
        songID: docRef.id,
        songUrl: songUrl,
        songDuration: _duration.inSeconds,
        namePage: _nameController.text.isNotEmpty
            ? _nameController.text
            : "Som sem título",
        hashtags: hashtags.isNotEmpty ? hashtags : null,
        categorie: _selectedCategory,
        priceInCents: _priceController.text.isNotEmpty
            ? int.tryParse(_priceController.text.replaceAll(',', ''))
            : null,
        currency: _priceController.text.isNotEmpty ? "BRL" : null,
        createdDateTime: createdDate,     // ✅ pode ser editado
        publishedDateTime: publishedDate, // ✅ sempre agora
        expiresAt: now.add(const Duration(hours: 24)),
        imageUrl: imageUrl,
        visibleOnMap: _visibleOnMap,
      );

      await docRef.set(publication.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Som publicado com sucesso!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Erro ao salvar publicação: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao publicar: $e")),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar para publicar')),
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _selectedImage != null
                          ? Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : Icon(Icons.audiotrack, size: 100, color: Colors.greenAccent),
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text(
                        "Selecionar capa",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        children: [Text(
                          'Arquivo: ',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                          Text(
                            widget.audioFile.path.split('/').last,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Slider com duração dentro de um Container
                        Expanded(
                          child: Container(
                            // se quiser largura fixa, use width: 150,
                            child: Column(
                              children: [
                                Slider(
                                  min: 0,
                                  max: _duration.inMilliseconds.toDouble(),
                                  value: _position.inMilliseconds
                                      .clamp(0, _duration.inMilliseconds)
                                      .toDouble(),
                                  onChanged: (value) async {
                                    final pos = Duration(milliseconds: value.toInt());
                                    await _player.seek(pos);
                                  },
                                  activeColor: Colors.greenAccent,
                                  inactiveColor: Colors.white30,
                                ),
                                // Duração apenas abaixo do slider
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_position),
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      _formatDuration(_duration),
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12), // Espaço entre slider e botão

                        // Botão de play/pause ao lado
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0), // padding nas laterais
                          child: SizedBox(
                            height: 48, // altura fixa
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24), // deixa tipo pílula
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16), // padding interno
                              ),
                              onPressed: () {
                                if (_isPlaying) _player.pause();
                                else _player.play();
                              },
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: Colors.black,
                      decoration: const InputDecoration(
                        labelText: "Categoria",
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: "Nome ou título",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: hashtags
                          .map((tag) => Chip(
                        label: Text("#$tag", style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.transparent,
                        onDeleted: () {
                          setState(() => hashtags.remove(tag));
                        },
                      ))
                          .toList(),
                    ),
                    TextField(
                      controller: _hashtagController,
                      decoration: const InputDecoration(
                        hintText: "Escolha até 3 #hashtags ex: #Música #love #bpm",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        final parts = value.split('#');
                        List<String> temp = [];

                        for (var part in parts) {
                          final trimmed = part.trim();
                          if (trimmed.isNotEmpty) {
                            temp.add(trimmed);
                          }
                        }

                        // Limita até 3 hashtags
                        if (temp.length > maxHashtags) {
                          temp = temp.sublist(0, maxHashtags);
                        }

                        setState(() {
                          hashtags = temp;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Switch com a pergunta
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mudar data de criação?",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Switch(
                              value: _editarData,
                              activeColor: Colors.white, // cor do botão ativo
                              inactiveThumbColor: Colors.white54, // cor do botão inativo
                              onChanged: (value) {
                                setState(() {
                                  _editarData = value;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Só mostra o TextField se o switch estiver ligado
                        if (_editarData)
                          TextField(
                            controller: _createdDateController,
                            cursorColor: Colors.white, // barra piscante do cursor
                            cursorWidth: 2.0,          // largura da barra
                            style: const TextStyle(color: Colors.white), // cor do texto
                            decoration: InputDecoration(
                              hintText: 'Data de criação ex: $dataAtual', // hint dinâmico
                              hintStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white), // borda padrão
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white), // borda quando em foco
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mostrar no mapa?",
                            style: TextStyle(
                              color: !_visibleOnMap ? Colors.red : Colors.greenAccent,
                              fontWeight: !_visibleOnMap ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            "Sim",
                            style: TextStyle(
                              color: _visibleOnMap ? Colors.greenAccent : Colors.white54,
                              fontWeight: _visibleOnMap ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Switch(
                            value: _visibleOnMap,
                            onChanged: (val) {
                              setState(() => _visibleOnMap = val);
                            },
                            activeColor: Colors.greenAccent,
                            inactiveThumbColor: Colors.white54,
                          ),
                          Text(
                            "Não",
                            style: TextStyle(
                              color: _visibleOnMap ? Colors.white54 : Colors.red,
                              fontWeight: _visibleOnMap ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              activeColor: Colors.greenAccent,
                              onChanged: (val) {
                                setState(() => _acceptedTerms = val ?? false);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Termos de Publicação"),
                                      content: const SingleChildScrollView(
                                        child: Text(
                                          "Ao publicar qualquer áudio (música, podcast, audiobook, etc), "
                                              "você declara que:\n\n"
                                              "• É o detentor dos direitos autorais OU possui autorização para compartilhar o conteúdo.\n"
                                              "• Não está violando direitos de terceiros.\n"
                                              "• Assume total responsabilidade legal pela publicação.\n"
                                              "• A plataforma não se responsabiliza por infrações cometidas pelos usuários.\n"
                                              "• O descumprimento pode resultar em remoção do conteúdo e bloqueio da conta.",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text("Fechar"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Li e aceito os termos de responsabilidade",
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUploading || !_acceptedTerms ? null : _savePublication,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Publicar Música"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
