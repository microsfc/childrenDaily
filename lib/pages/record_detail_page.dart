import './../models/baby_record.dart';
import 'package:flutter/material.dart';
import '../widgets/zoomable_photo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({Key? key, required this.record}) : super(key: key);

  static const routeName = '/record_detail';
  final BabyRecord record;

  Future<void> confirmDeleteRecord(BuildContext context) async {
    // 彈出確認刪除的 dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('確定要刪除嗎？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('取消')),
          TextButton(
              onPressed: () => {
                    deleteRecord(),
                    Navigator.of(context).pop(),
                    Navigator.of(context).pop(),
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('成功刪除紀錄！')),
                    )
                  },
              child: Text('確定')),
        ],
      ),
    );
  }

  Future<void> deleteRecord() async {
    await FirebaseFirestore.instance
        .collection('baby_records')
        .doc(record.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = record.date.toLocal().toString().split(' ')[0];
    final noteDesc = record.note.isNotEmpty ? record.note : 'No note';
    final vaccineText = record.vaccineStatus.isNotEmpty
        ? 'Vaccine: ${record.vaccineStatus}'
        : 'No vaccine';
    final heightText =
        record.height.isNotEmpty ? 'Height: ${record.height}' : 'No height';
    final weightText =
        record.weight.isNotEmpty ? 'Weight: ${record.weight}' : 'No weight';

    return Scaffold(
        appBar: AppBar(
          title: Text('活動記錄 Detail'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // show photo if available
              if (record.photoUrl.isNotEmpty) ...[
                // Container(
                //   margin: const EdgeInsets.all(16),
                //   child: record.photoUrl.isNotEmpty
                //       ? Image.network(record.photoUrl,
                //           width: 200, height: 200, fit: BoxFit.cover)
                //       : const Icon(Icons.photo, size: 200),
                // ),
                Hero(
                  tag: 'recordPhoto_${record.id}',
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZoomablePhotoPage(
                            imageUrl: record.photoUrl,
                            heroTag: 'recordPhoto_${record.id}',
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      record.photoUrl,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
              // date,
              Text('日期: $dateStr',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              // vaccine status
              Text('疫苗狀況: $vaccineText',
                  style: Theme.of(context).textTheme.bodyMedium),
              // height
              Text('身高: $heightText',
                  style: Theme.of(context).textTheme.bodyMedium),
              // weight
              Text('體重: $weightText',
                  style: Theme.of(context).textTheme.bodyMedium),
              // note
              Text('備註: $noteDesc',
                  style: Theme.of(context).textTheme.bodyMedium),
              // tags
              if (record.tags.isNotEmpty) ...[
                Text('標籤: ${record.tags.join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    onPressed: () {
                      confirmDeleteRecord(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
