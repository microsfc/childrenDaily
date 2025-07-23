import 'package:flutter/material.dart';

class InfoItemComponent extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const InfoItemComponent({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6c757d),
          ),
        ),
      ],
    );
  }
}