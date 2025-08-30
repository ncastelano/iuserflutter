import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../profile/profile_model.dart';
import '../profile/profile_page.dart';
import '../profile/profile_screen.dart';

class ListProfile extends StatelessWidget {


  Widget buildImage(String urlImage) => Image.network(
    urlImage,
    fit: BoxFit.cover,
    width: 100,
    height: 100,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Perfis'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar perfis'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum perfil encontrado'));
          }

          // Converte os documentos do Firestore em uma lista de ProfileModel
          final userDocs = snapshot.data!.docs;
          List<ProfileModel> profiles = userDocs.map((doc) {
            // Inclui o ID do documento ao criar o ProfileModel
            return ProfileModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];

              return ListTile(
                leading: Hero(
                  tag: profile, // Usando a mesma tag para animação Hero
                  child: buildImage(profile.image),
                ),
                title: Text(profile.name),
                subtitle: Text(profile.email), // Exibe o email do usuário
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      reverseTransitionDuration: Duration(milliseconds: 1000),
                      transitionDuration: Duration(milliseconds: 1500),// Tempo de transição na volta
                      pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(profile: profile),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },

              );
            },
          );
        },
      ),
    );
  }
}
