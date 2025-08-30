import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StorePage extends StatelessWidget {
  final String storePostID;

  const StorePage({Key? key, required this.storePostID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loja", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("videos")
            .doc(storePostID)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar loja"));
          }

          final storeData = snapshot.data?.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BANNER PRINCIPAL (THUMBNAIL + NOME) ---
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.network(
                      storeData['thumbnailUrl'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                      child: Text(
                        storeData['artistSongName'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // --- SLOGAN ---
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Moda sustentável com estilo único! ✨",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),

                // --- INFORMAÇÕES DA LOJA ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Seg-Sex: 9h às 18h | Sáb: 10h às 14h",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Rua das Flores, 123 - São Paulo",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "(11) 98765-4321",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(height: 30, thickness: 1),

                // --- PRODUTOS EM DESTAQUE ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Produtos em Destaque",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildProductItem("Camiseta Verde", "R\$ 59,90", "https://exemplo.com/img1.jpg"),
                            _buildProductItem("Calça Jeans", "R\$ 129,90", "https://exemplo.com/img2.jpg"),
                            _buildProductItem("Tênis Casual", "R\$ 199,90", "https://exemplo.com/img3.jpg"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 30, thickness: 1),

                // --- SEÇÃO DE CURTIDAS E INTERAÇÕES ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 20),
                          SizedBox(width: 4),
                          Text(
                            "1.2K curtidas",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.comment, color: Colors.grey, size: 20),
                          SizedBox(width: 4),
                          Text(
                            "328 comentários",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // --- FOTOS DE CLIENTES ---
                      Text(
                        "Clientes que compraram aqui:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCustomerPhoto("https://randomuser.me/api/portraits/women/44.jpg"),
                            _buildCustomerPhoto("https://randomuser.me/api/portraits/men/32.jpg"),
                            _buildCustomerPhoto("https://randomuser.me/api/portraits/women/68.jpg"),
                            _buildCustomerPhoto("https://randomuser.me/api/portraits/men/75.jpg"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 30, thickness: 1),

                // --- COMENTÁRIOS ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Comentários",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildComment(
                        "Ana Silva",
                        "https://randomuser.me/api/portraits/women/44.jpg",
                        "Adorei a qualidade dos produtos! Entrega super rápida.",
                        "2 dias atrás",
                      ),
                      _buildComment(
                        "Carlos Souza",
                        "https://randomuser.me/api/portraits/men/32.jpg",
                        "O atendimento foi incrível. Recomendo!",
                        "1 semana atrás",
                      ),
                    ],
                  ),
                ),

                // --- BOTÕES DE AÇÃO ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text("Fale Conosco via WhatsApp"),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.deepPurple),
                          ),
                          child: Text(
                            "Siga-nos no Instagram",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget auxiliar para produtos
  Widget _buildProductItem(String name, String price, String imageUrl) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 120,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            price,
            style: TextStyle(color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para fotos de clientes
  Widget _buildCustomerPhoto(String photoUrl) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(photoUrl),
      ),
    );
  }

  // Widget auxiliar para comentários
  Widget _buildComment(String user, String userPhoto, String comment, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(userPhoto),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(comment),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}