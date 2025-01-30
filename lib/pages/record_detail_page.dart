import 'zoomable_photo_page.dart';
import './../models/baby_record.dart';
import 'package:flutter/material.dart';
import 'package:children/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({Key? key, required this.record}) : super(key: key);

  static const routeName = '/record_detail';
  final BabyRecord record;

  Future<void> confirmDeleteRecord(BuildContext context) async {
    // 彈出確認刪除的 dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).areYouSureToDelete),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text(S.of(context).cancel)),
          TextButton(
              onPressed: () => {
                    deleteRecord(),
                    Navigator.of(context).pop(),
                    Navigator.of(context).pop(),
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).deleteSuccess)),
                    )
                  },
              child: Text(S.of(context).confirm)),
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
    final noteDesc = record.note.isNotEmpty ? record.note : S.of(context).noNote;
    final vaccineText = record.vaccineStatus.isNotEmpty
        ? record.vaccineStatus
        : 'No Data';
    final heightText =
        record.height.isNotEmpty ? '${record.height} (kg)' : 'No height';
    final weightText =
        record.weight.isNotEmpty ? '${record.weight} (cm)' : 'No weight';

    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).recordDetail),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // show photo if available
              if (record.photoUrl.isNotEmpty) ...[ 
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
                    child: CachedNetworkImage(imageUrl: record.photoUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  memCacheWidth: 200,
                  errorWidget:(context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover),
                  ),
                )
              ],
              // date,
              Text('${S.of(context).selectDate}: $dateStr',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              // vaccine status
              Text('${S.of(context).vaccineStatus}: $vaccineText',
                  style: Theme.of(context).textTheme.bodyMedium),
              // height
              Text('${S.of(context).height}: $heightText',
                  style: Theme.of(context).textTheme.bodyMedium),
              // weight
              Text('${S.of(context).weight}: $weightText',
                  style: Theme.of(context).textTheme.bodyMedium),
              // note
              Text('${S.of(context).diary}: $noteDesc',
                  style: Theme.of(context).textTheme.bodyMedium),
              // tags
              if (record.tags.isNotEmpty) ...[
                Text('${S.of(context).tag} ${record.tags.join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text(S.of(context).delete),
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
