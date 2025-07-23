import 'package:flutter/material.dart';
import 'package:children/widgets/info_item_component.dart';

class InfoPanelComponent extends StatelessWidget {
  final double height;
  final double weight;
  final String location;

  const InfoPanelComponent({
    Key? key,
    required this.height,
    required this.weight,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InfoItemComponent(
            icon: Icons.height,
            text: "$height cm",
            color: Color(0xFF3498db),
          ),
          InfoItemComponent(
            icon: Icons.monitor_weight,
            text: "$weight kg",
            color: Color(0xFF27ae60),
          ),
          InfoItemComponent(
            icon: location == "home" ? Icons.home : Icons.location_on,
            text: location,
            color: Color(0xFFf39c12),
          ),
        ],
      ),
    );
  }
}
