import 'package:flutter/material.dart';

class CardHeaderComponent extends StatelessWidget {
  final String date;
  final String emoji;

  const CardHeaderComponent({
    super.key,
    required this.date,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}