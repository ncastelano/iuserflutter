import 'dart:math';
import 'package:flutter/material.dart';

class LoginButton extends StatefulWidget {
  final VoidCallback onTap;

  const LoginButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>
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
    final double outerWidth = MediaQuery.of(context).size.width - 60;
    final double outerHeight = 55;
    final double borderSize = 4; // Tamanho da "borda" colorida

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Container maior com gradiente giratório (borda)
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return SweepGradient(
                      startAngle: 0,
                      endAngle: 2 * pi,
                      colors: const [
                        Colors.red,
                        Colors.orange,
                        Colors.blue,
                        Colors.purple,
                        Colors.red,
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      transform: GradientRotation(2 * pi * _controller.value),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    width: outerWidth,
                    height: outerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              // Container menor na frente para criar a borda
              Container(
                width: outerWidth - borderSize * 2,
                height: outerHeight - borderSize * 2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black, // cor do fundo da área interna
                  borderRadius: BorderRadius.circular(30 - borderSize),
                ),
                child: const Text(
                  "Entrar",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
