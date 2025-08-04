import 'package:flutter/material.dart';
import 'package:children/models/baby_record.dart';
import 'package:children/widgets/card_header_component.dart';
import 'package:children/widgets/timeline_dot_component.dart';
import 'package:children/widgets/card_content_component.dart';

class RecordCardComponent extends StatelessWidget {
  BabyRecord record;
  final int index;
  final int recordLength;
  final ScrollController _scrollController;
  final Function(BabyRecord)? onTap;
  final Function(BabyRecord)? onLongPress;
  final Function(int, BabyRecord)? onRecordUpdated;

  RecordCardComponent({super.key, required this.record, required this.index,
        required this.recordLength, required ScrollController scrollController, this.onRecordUpdated, this.onTap, this.onLongPress})
      : _scrollController = scrollController;

  @override
  Widget build(BuildContext context) {
    // Calculate parallax effect based on scroll position
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
    print('Scroll offset: $scrollOffset');
    final parallaxOffset = scrollOffset * 0.1 * (index + 1);
    // print for debugging parallax offset
    print('Parallax offset for index $index: $parallaxOffset');
    // Determine if this is the last record to avoid drawing the line
    // after the last dot
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
                        onTap: () async {
                          if (onTap != null) {
                            onTap!(record);
                          } else {
                            final modifyRecord = await Navigator.of(context).pushNamed(
                              '/record_detail',
                              arguments: record,
                            );
                            if (modifyRecord is BabyRecord) {
                              record = modifyRecord;
                              if (onRecordUpdated != null) {
                                onRecordUpdated!(index, modifyRecord);
                              }
                            }
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