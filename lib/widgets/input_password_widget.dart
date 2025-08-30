import 'package:flutter/material.dart';

class InputPasswordWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const InputPasswordWidget({
    Key? key,
    required this.controller,
    this.label = "Senha",
  }) : super(key: key);

  @override
  _InputPasswordWidgetState createState() => _InputPasswordWidgetState();
}

class _InputPasswordWidgetState extends State<InputPasswordWidget> {
  bool _obscureText = true;
  String _passwordStrengthText = "";
  Color _strengthColor = Colors.grey;

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrengthText = "";
        _strengthColor = Colors.grey;
      });
      return;
    }

    if (password.length < 6) {
      _passwordStrengthText = "Muito fraca";
      _strengthColor = Colors.red;
    } else if (password.length < 8) {
      _passwordStrengthText = "Fraca";
      _strengthColor = Colors.orange;
    } else if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      _passwordStrengthText = "Forte";
      _strengthColor = Colors.green;
    } else {
      _passwordStrengthText = "Média";
      _strengthColor = Colors.yellow[700]!;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      checkPasswordStrength(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: const Icon(Icons.lock_outline), // ícone de chave à esquerda
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_passwordStrengthText.isNotEmpty)
          Text(
            "Força da senha: $_passwordStrengthText",
            style: TextStyle(
              color: _strengthColor,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
