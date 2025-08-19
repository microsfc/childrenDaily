import 'package:flutter/material.dart';

class FormContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderTopColor;
  final double borderTopWidth;

  const FormContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.backgroundColor,
    this.borderTopColor = const Color(0xFF4A90E2),
    this.borderTopWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: borderTopWidth,
                color: borderTopColor!,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
