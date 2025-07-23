import 'package:flutter/material.dart';

class TimelineDotComponent extends StatelessWidget {
  final bool isLast;
  final double parallaxOffset;

  const TimelineDotComponent({
    super.key,
    required this.isLast,
    required this.parallaxOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0, parallaxOffset * 0.1),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFff9a9e), Color(0xFFfecfef)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFff9a9e).withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          if (!isLast)
            Container(
              width: 4,
              height: 100,
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFfecfef), Color(0xFFff9a9e)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}