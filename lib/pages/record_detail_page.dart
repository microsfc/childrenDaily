import 'zoomable_photo_page.dart';
import './../models/baby_record.dart';
import '../models/record_detail.dart';
import 'package:flutter/material.dart';
import 'package:children/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecordDetailPage extends StatefulWidget {
  final BabyRecord record;
  const RecordDetailPage({super.key, required this.record});
  static const routeName = '/record_detail';

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late String dateTime;
  late String noteDesc;
  late String vaccineText;
  late String heightText;
  late String weightText;
  var tags = [];
  late String photoUrl;
  late String heroTag;

  @override
  void initState() {
    super.initState();
    // 初始化資料
    dateTime = widget.record.date.toLocal().toString().split(' ')[0];
    noteDesc = widget.record.note.isNotEmpty ? widget.record.note : S.of(context).noNote;
    vaccineText = widget.record.vaccineStatus.isNotEmpty
        ? widget.record.vaccineStatus
        : 'No Data';
    heightText =
        widget.record.height.isNotEmpty ? '${widget.record.height} (kg)' : 'No height';
    weightText =
        widget.record.weight.isNotEmpty ? '${widget.record.weight} (cm)' : 'No weight';
    photoUrl = widget.record.photoUrl;
    tags = widget.record.tags;
    heroTag = 'recordPhoto_${widget.record.id}';
  }

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
        .doc(widget.record.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
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
              if (photoUrl.isNotEmpty) ...[ 
                Hero(
                  tag: heroTag,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZoomablePhotoPage(
                            imageUrl: photoUrl,
                            heroTag: heroTag,
                          ),
                        ),
                      );
                    },
                    child: CachedNetworkImage(imageUrl: photoUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  memCacheWidth: 200,
                  errorWidget:(context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover),
                  ),
                )
              ],
              // date,
              Text('${S.of(context).selectDate}: $dateTime',
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
              if (tags.isNotEmpty) ...[
                Text('${S.of(context).tag} ${tags.join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text(S.of(context).edit),
                    onPressed: () async {
                      final changeData = await Navigator.of(context).pushNamed(
                        '/add_record',
                        arguments: widget.record,
                      );
                      
                      setState(() {
                        // 更新顯示的資料                        
                        if (changeData is RecordDetail) {
                          dateTime = changeData.dateTime.toString().split(' ')[0];
                          photoUrl = changeData.photoUrl;
                          noteDesc = changeData.note.isNotEmpty ? changeData.note : S.of(context).noNote;
                          vaccineText = changeData.vaccineStatus.isNotEmpty
                              ? changeData.vaccineStatus
                              : 'No Data';
                          heightText =
                              changeData.height.isNotEmpty ? '${changeData.height} (cm)' : 'No height';
                          weightText =
                              changeData.weight.isNotEmpty ? '${changeData.weight} (kg)' : 'No weight';
                          tags = changeData.tags;
                          // Update hero tag to force Hero widget to refresh
                          heroTag = 'recordPhoto_${DateTime.now().millisecondsSinceEpoch}';
                        }
                      });
                    },
                  ),
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
