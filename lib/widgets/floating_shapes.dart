import 'package:flutter/material.dart';

class FloatingShapes extends StatelessWidget {
  final List<FloatingShapeData> shapes;

  const FloatingShapes({super.key, required this.shapes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: shapes.map((shape) {
        return Positioned(
          top: shape.top,
          left: shape.left,
          right: shape.right,
          bottom: shape.bottom,
          child: FloatingShape(
            emoji: shape.emoji,
            delay: shape.delay,
          ),
        );
      }).toList(),
    );
  }
}

class FloatingShape extends StatefulWidget {
  final String emoji;
  final int delay;

  const FloatingShape({super.key, required this.emoji, required this.delay});

  @override
  State<FloatingShape> createState() => _FloatingShapeState();
}

class _FloatingShapeState extends State<FloatingShape> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(seconds: 6 + widget.delay),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (0.5 - (value - 0.5).abs()) * 2),
          child: Transform.rotate(
            angle: value * 6.28,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        );
      },
      onEnd: () {
        setState(() {});
      },
    );
  }
}

class FloatingShapeData {
  final String emoji;
  final int delay;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const FloatingShapeData({
    required this.emoji,
    required this.delay,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });
}
