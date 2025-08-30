
// Página de Entretenimento
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EntretenimentoPage extends StatelessWidget {
  const EntretenimentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.whatshot, size: 100, color: Colors.white),
            Text(
              'Entretenimento',
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
