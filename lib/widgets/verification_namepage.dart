import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageNameInputWidget extends StatefulWidget {
  final TextEditingController controller;

  const PageNameInputWidget({Key? key, required this.controller}) : super(key: key);

  @override
  _PageNameInputWidgetState createState() => _PageNameInputWidgetState();
}

class _PageNameInputWidgetState extends State<PageNameInputWidget> {
  bool? isAvailable; // null = ainda não checou
  bool isChecking = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para checar se já existe o nome no Firestore
  void checkAvailability(String namePage) async {
    if (namePage.isEmpty) {
      setState(() {
        isAvailable = null;
      });
      return;
    }

    setState(() {
      isChecking = true;
    });

    final querySnapshot = await _firestore
        .collection('users')
        .where('namePage', isEqualTo: namePage)
        .get();

    setState(() {
      isAvailable = querySnapshot.docs.isEmpty;
      isChecking = false;
    });
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      final text = widget.controller.text.trim();

      // Delay para evitar muitas requisições enquanto digita
      Future.delayed(const Duration(milliseconds: 500), () {
        if (text == widget.controller.text.trim()) {
          checkAvailability(text);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (isAvailable == null) {
      borderColor = Colors.grey;
    } else if (isAvailable == true) {
      borderColor = Colors.green;
    } else {
      borderColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Parte fixa: http://iuser.com.br/
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              border: Border(
                top: BorderSide(color: borderColor, width: 2),
                bottom: BorderSide(color: borderColor, width: 2),
                left: BorderSide(color: borderColor, width: 2),
                // removido o borderRight
              ),
            ),
            child: const Text(
              "http://iuser.com.br/",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),

          // Campo editável: suapaginaiuser
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: "suapaginaiuser",
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                suffixIcon: isChecking
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : (isAvailable == true
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : isAvailable == false
                    ? const Icon(Icons.error, color: Colors.red)
                    : null),
              ),
              // Para remover o lado esquerdo da borda do TextField:
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      )
      ,
    );
  }
}
