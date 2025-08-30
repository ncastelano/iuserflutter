import 'dart:math';
import 'package:flutter/material.dart';

class ButtonEffect extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double width;
  final double height;

  const ButtonEffect({
    Key? key,
    required this.text,
    required this.onTap,
    this.width = double.infinity,
    this.height = 50,
  }) : super(key: key);

  @override
  State<ButtonEffect> createState() => _ButtonEffectState();
}

class _ButtonEffectState extends State<ButtonEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final angle = 2 * pi * _controller.value;

        // Cálculo do deslocamento da sombra baseado no ângulo
        final dx = 6 * cos(angle);
        final dy = 6 * sin(angle);

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Colors.blue, Colors.red, Colors.yellow, Colors.green],
                transform: GradientRotation(angle),
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(dx, dy), // movimento da sombra animado
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
