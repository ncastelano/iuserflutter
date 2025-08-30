import 'package:flutter/material.dart';

class ProfileScreen2 extends StatelessWidget {
  const ProfileScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('Flashs'),
          _buildHorizontalList(['Flash 1', 'Flash 2', 'Flash 3']),
          const SizedBox(height: 24),
          _buildSectionTitle('Locais'),
          _buildHorizontalList(['Praia', 'Parque', 'Restaurante']),
          const SizedBox(height: 24),
          _buildSectionTitle('Loja'),
          _buildProductGrid(),
          const SizedBox(height: 24),
          _buildSectionTitle('Comentários'),
          _buildComments(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Nome do Usuário',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _StatItem(title: 'Sigo', value: '120'),
            SizedBox(width: 24),
            _StatItem(title: 'Seguidores', value: '350'),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHorizontalList(List<String> items) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (_, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12, top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                items[index],
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = ['Produto 1', 'Produto 2', 'Produto 3', 'Produto 4'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (_, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag, color: Colors.white, size: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  products[index],
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildComments() {
    final comments = [
      {'user': 'Ana', 'text': 'Adorei seus flashs!'},
      {'user': 'João', 'text': 'Top demais!'},
      {'user': 'Maria', 'text': 'Lugar lindo que você marcou!'},
    ];

    return Column(
      children: comments.map((comment) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
          title: Text(comment['user']!, style: const TextStyle(color: Colors.white)),
          subtitle: Text(comment['text']!, style: const TextStyle(color: Colors.white70)),
        );
      }).toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
