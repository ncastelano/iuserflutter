import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileStoreOrProduct extends StatelessWidget {
  const ProfileStoreOrProduct({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> data = [
      {
        'name': 'Loja do João',
        'avatarUrl': 'https://via.placeholder.com/100',
        'rating': 4.5,
        'products': [
          {'name': 'Tesoura Pro', 'price': 29.9},
          {'name': 'Shampoo X', 'price': 12.0},
          {'name': 'Secador Turbo', 'price': 199.0},
        ],
      },
      {
        'name': 'Loja da Ana',
        'avatarUrl': 'https://via.placeholder.com/100',
        'rating': 5.0,
        'products': [
          {'name': 'Creme Facial', 'price': 49.9},
        ],
      },
      {
        'name': 'Loja do Pedro',
        'avatarUrl': 'https://via.placeholder.com/100',
        'rating': 4.2,
        'products': [
          {'name': 'Gel Capilar', 'price': 14.0},
          {'name': 'Pomada Matte', 'price': 22.5},
        ],
      },
      {
        'name': null, // Produto sem loja
        'products': [
          {'name': 'Produto Solto', 'price': 9.9},
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Loja ou Produto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final entry = data[index];
              final String? storeName = entry['name'];
              final String? avatarUrl = entry['avatarUrl'];
              final double? rating = entry['rating'];
              final List<dynamic> products = entry['products'] ?? [];

              final List<double> prices = products.map((p) => (p['price'] as num).toDouble()).toList();
              final double minPrice = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;
              final double maxPrice = prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b) : 0.0;

              // Loja com produtos
              if (storeName != null) {
                return Container(
                  width: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(avatarUrl ?? ''),
                            radius: 24,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storeName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < rating!.floor()
                                        ? Icons.star
                                        : i < rating
                                        ? Icons.star_half
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${minPrice.toStringAsFixed(2)} - R\$ ${maxPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, i) {
                            final product = products[i];
                            return Container(
                              width: 90,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'R\$ ${product['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Apenas produto
              final product = products.isNotEmpty ? products.first : null;

              return Container(
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[900],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/iuserprojeto.appspot.com/o/All%20Thumbnails%2F0SxyNyFUaM20dYnidbJj?alt=media&token=66ab42c5-b04e-45c5-a86d-adf34f6ef250',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              color: Colors.black.withOpacity(0.1),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'R\$ ${product['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
