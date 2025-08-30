import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedLoginButton extends StatefulWidget {
  final VoidCallback onTap;
  const AnimatedLoginButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<AnimatedLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isPressed = false;

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
    final double borderSize = 4;

    List<double> opacities = isPressed ? [1.0, 0.5, 0.2] : [0.5, 0.2, 0.05];
    List<double> scaleFactors = [1.0, 1.1, 1.2];

    return GestureDetector(
      onTap: () {
        setState(() => isPressed = true);
        widget.onTap();
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() => isPressed = false);
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < 3; i++)
                Transform.scale(
                  scale: scaleFactors[i],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return SweepGradient(
                          startAngle: 0,
                          endAngle: 2 * pi,
                          colors: [
                            Colors.red.withOpacity(opacities[i]),
                            Colors.orange.withOpacity(opacities[i]),
                            Colors.blue.withOpacity(opacities[i]),
                            Colors.purple.withOpacity(opacities[i]),
                            Colors.red.withOpacity(opacities[i]),
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
                ),
              Container(
                width: outerWidth - borderSize * 2,
                height: outerHeight - borderSize * 2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
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
          );
        },
      ),
    );
  }
}
