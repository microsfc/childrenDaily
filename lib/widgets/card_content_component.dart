import 'tags_component.dart';
import 'package:flutter/material.dart';
import 'package:children/models/baby_record.dart';
import 'package:children/widgets/info_panel_component.dart';
import 'package:children/widgets/photo_area_component.dart';

class CardContentComponent extends StatelessWidget {
  final BabyRecord record;

  const CardContentComponent({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoAreaComponent(record: record),
          SizedBox(height: 12),
          Text(
            record.vaccineStatus,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2c3e50),
            ),
          ),
          SizedBox(height: 8),
          Text(
            record.note,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6c757d),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          InfoPanelComponent(
            height: double.tryParse(record.height) ?? 0.0,
            weight: double.tryParse(record.weight) ?? 0.0,
            location: 'home',
          ),
          SizedBox(height: 12),
          TagsComponent(tags: record.tags),
        ],
      ),
    );
  }
}