import 'package:flutter/material.dart';

class InputTextWidget extends StatelessWidget
{
  final TextEditingController textEditingController;
  final IconData? iconData;
  final String? assetRefrence;
  final String lableString;
  final bool isObscure;

  InputTextWidget(
  {
    required this.textEditingController,
    this.iconData,
    this.assetRefrence,
    required this.lableString,
    required this.isObscure,
  });



  @override
  Widget build(BuildContext context)
  {
    return TextField(
      controller: textEditingController,
      cursorColor: Colors.white,  // muda a cor do cursor piscando
      decoration: InputDecoration(
        labelText: lableString,
        floatingLabelStyle: const TextStyle(
          color: Colors.white,  // cor da label quando sobe/focada
          fontSize: 18,
        ),
        prefixIcon: iconData != null
            ? Icon(iconData)
            : Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(assetRefrence!, width: 10),
        ),
        labelStyle: const TextStyle(
          fontSize: 18,
          color: Colors.grey,  // cor da label quando não focada
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Colors.white,  // muda a borda quando focado para branco, opcional
          ),
        ),
      ),
      obscureText: isObscure,
    );
  }
}
