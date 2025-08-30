import 'package:flutter/material.dart';

class ProfileLinks extends StatelessWidget {
  const ProfileLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start, // garante alinhamento do título à esquerda
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8),
            child: Text(
              'Perfis em outras redes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                Icon(Icons.link, color: Colors.white),
                Icon(Icons.video_library, color: Colors.red),
                Icon(Icons.facebook, color: Colors.blue),
                Icon(Icons.code, color: Colors.greenAccent),
                Icon(Icons.business, color: Colors.blueGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
