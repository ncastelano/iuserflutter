import 'package:flutter/material.dart';

class ProfileAgenda extends StatelessWidget {
  const ProfileAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> agenda = [
      {
        'person': 'João Silva',
        'service': 'Corte de cabelo',
        'hour': '14:00',
      },
      {
        'person': 'Maria Souza',
        'service': 'Design de sobrancelha',
        'hour': '16:30',
      },
      {
        'person': 'Carlos Lima',
        'service': 'Barba completa',
        'hour': '18:00',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Agenda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...agenda.map(
              (item) => ListTile(
            leading: const Icon(Icons.schedule, color: Colors.white),
            title: Text(
              '${item['service']} com ${item['person']}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Horário: ${item['hour']}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
