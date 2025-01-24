import 'package:flutter/material.dart';
import '../models/baby_record.dart';
import '../widgets/record_tile.dart';

class DailyRecordsPage extends StatelessWidget {
  final DateTime date;
  final List<BabyRecord> records;
  static const routeName = '/daily_records';

  const DailyRecordsPage(
      {super.key, required this.date, required this.records});

  @override
  Widget build(BuildContext context) {
    // 格式化日期字串 (只顯示 yyyy-MM-dd)
    final dateString =
        '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
    return Scaffold(
      appBar: AppBar(title: Text('$dateString 的紀錄')),
      body: records.isEmpty
          ? const Center(child: Text('今日沒有紀錄'))
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return RecordTile(record: record);
              }),
    );
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
