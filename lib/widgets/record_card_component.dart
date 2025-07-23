import 'package:flutter/material.dart';
import 'package:children/models/baby_record.dart';
import 'package:children/widgets/card_header_component.dart';
import 'package:children/widgets/timeline_dot_component.dart';
import 'package:children/widgets/card_content_component.dart';

class RecordCardComponent extends StatelessWidget {
  final BabyRecord record;
  final int index;
  final int recordLength;
  final ScrollController _scrollController;
  final Function(BabyRecord)? onTap;
  final Function(BabyRecord)? onLongPress;

  const RecordCardComponent({super.key, required this.record, required this.index,
        required this.recordLength, required ScrollController scrollController, this.onTap, this.onLongPress})
      : _scrollController = scrollController;

  @override
  Widget build(BuildContext context) {
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
    final parallaxOffset = scrollOffset * 0.1 * (index + 1);
    final isLast = (index == recordLength - 1);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: 
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimelineDotComponent(
                      isLast: isLast,
                      parallaxOffset: parallaxOffset,
                    ),
            SizedBox(width: 20),
            Expanded(
              child: InkWell(
                        onTap: () {
                          if (onTap != null) {
                            onTap!(record);
                          } else {
                            Navigator.of(context).pushNamed(
                              '/record_detail',
                              arguments: record,
                            );
                          }
                        },
                        onLongPress: () {
                          if (onLongPress != null) {
                            onLongPress!(record);
                          }
                        },
                        child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardHeaderComponent(
                                date: record.formattedDate,
                                emoji: record.emoji,
                              ),
                              CardContentComponent(record: record),
                            ],
                          ),
              ),
            )
          ],
        ),
    );
  }
}