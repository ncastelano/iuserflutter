import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IUserEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderSize;

  const IUserEffect({
    Key? key,
    required this.child,
    this.onTap,
    this.borderSize = 4,
  }) : super(key: key);

  @override
  IUserEffectState createState() => IUserEffectState();
}

class IUserEffectState extends State<IUserEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Duration normalDuration = const Duration(seconds: 10);
  final Duration fastDuration = const Duration(milliseconds: 1000);
  Timer? _speedTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: normalDuration,
      vsync: this,
    )..repeat();
  }

  void accelerate() {
    _controller.duration = fastDuration;
    _controller
      ..reset()
      ..repeat();

    _speedTimer?.cancel();
    _speedTimer = Timer(const Duration(seconds: 2), () async {
      const steps = 30;
      const totalTransitionDuration = Duration(milliseconds: 1000);
      final tickDuration = Duration(milliseconds: totalTransitionDuration.inMilliseconds ~/ steps);

      for (int i = 0; i <= steps; i++) {
        if (!mounted) return;

        final t = i / steps;
        final interpolatedDuration = Duration(
          milliseconds: (fastDuration.inMilliseconds * (1 - t) + normalDuration.inMilliseconds * t).toInt(),
        );

        if (!mounted) return;
        _controller.duration = interpolatedDuration;
        _controller
          ..reset()
          ..repeat();

        await Future.delayed(tickDuration);
      }

      if (mounted) {
        _controller.duration = normalDuration;
        _controller
          ..reset()
          ..repeat();
      }
    });
  }

  void _handleTap() {
    widget.onTap?.call();
    accelerate();
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final rotation = _controller.value * 2 * pi;
            return Container(
              padding: EdgeInsets.all(widget.borderSize),
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  startAngle: 0,
                  endAngle: 2 * pi,
                  colors: [...colors, colors.first],
                  stops: List.generate(colors.length + 1, (i) => i / colors.length),
                  transform: GradientRotation(rotation),
                ),
                boxShadow: [
                  for (int i = 0; i < colors.length; i++)
                    BoxShadow(
                      color: colors[i].withOpacity(0.2),
                      blurRadius: 2,
                      offset: Offset.fromDirection(
                        rotation + (i / colors.length) * 2 * pi,
                        3.0,
                      ),
                    ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30 - widget.borderSize),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Center(child: widget.child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}