import 'package:flutter/material.dart';

class ProfileComment extends StatelessWidget {
  const ProfileComment({super.key});

  String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> comments = [
      {
        'name': 'Fulano',
        'text': 'Excelente profissional!',
        'images': ['https://placekitten.com/200/200'],
        'likes': 12,
        'time': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'name': 'Beltrano',
        'text': 'Super confiável e pontual!',
        'images': [
          'https://placekitten.com/201/201',
          'https://placekitten.com/202/202',
        ],
        'likes': 8,
        'time': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'name': 'Ciclano',
        'text': 'Serviço rápido e excelente.',
        'images': [],
        'likes': 5,
        'time': DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        'name': 'Maria',
        'text': 'Recomendo demais!',
        'images': ['https://placekitten.com/203/203'],
        'likes': 20,
        'time': DateTime.now().subtract(const Duration(minutes: 30)),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'O que dizem sobre mim',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          itemCount: comments.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final comment = comments[index];
            final List<String> images = List<String>.from(comment['images']);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome + curtidas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.favorite,
                              color: Colors.pinkAccent[100], size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${comment['likes']}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Texto do comentário
                  Text(
                    comment['text'],
                    style: const TextStyle(color: Colors.white),
                  ),

                  // Lista horizontal de imagens
                  if (images.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        itemBuilder: (context, imgIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                images[imgIndex],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),

                  // Tempo do comentário
                  Text(
                    _timeAgo(comment['time']),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
