import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileEdit extends StatefulWidget {
  final String userID;

  ProfileEdit({required this.userID});

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _youtubeController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _facebookController;

  @override
  void initState() {
    super.initState();
    // Inicializando os controladores de texto
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _youtubeController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _facebookController = TextEditingController();

    _loadUserData();
  }

  @override
  void dispose() {
    // Liberando os controladores ao sair da tela
    _nameController.dispose();
    _emailController.dispose();
    _youtubeController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  // Carrega os dados do usuário para os campos de edição
  Future<void> _loadUserData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userID)
        .get();

    if (docSnapshot.exists) {
      final userData = docSnapshot.data() as Map<String, dynamic>;
      _nameController.text = userData['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _youtubeController.text = userData['youtube'] ?? '';
      _instagramController.text = userData['instagram'] ?? '';
      _twitterController.text = userData['twitter'] ?? '';
      _facebookController.text = userData['facebook'] ?? '';
    }
  }

  // Atualiza os dados no Firestore
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'youtube': _youtubeController.text,
        'instagram': _instagramController.text,
        'twitter': _twitterController.text,
        'facebook': _facebookController.text,
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userID)
            .update(updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context, 'updated');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _youtubeController,
                  decoration: InputDecoration(labelText: 'YouTube'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _instagramController,
                  decoration: InputDecoration(labelText: 'Instagram'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _twitterController,
                  decoration: InputDecoration(labelText: 'Twitter'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _facebookController,
                  decoration: InputDecoration(labelText: 'Facebook'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text('Salvar Alterações'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
