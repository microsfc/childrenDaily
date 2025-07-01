import 'zoomable_photo_page.dart';
import './../models/baby_record.dart';
import '../models/record_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children/state/AppState.dart';
import 'package:children/generated/l10n.dart';
import 'package:children/bloc/record_bloc.dart';
import 'package:children/bloc/record_event.dart';
import 'package:children/pages/add_record_page.dart';
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
  late BabyRecord afterModifyRecord;

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
    afterModifyRecord = widget.record;
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
                    // 刪除資料
                    context.read()<RecordBloc>().add(
                      DeleteRecordEvent(widget.record.id, AppState.of(context).uid),
                    ),
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
              SizedBox(height: 20),
              // date,
              Text('${S.of(context).selectDate}: $dateTime',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 10),
              // vaccine status
              Text('${S.of(context).vaccineStatus}: $vaccineText',
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10),
              // height
              Text('${S.of(context).height}: $heightText',
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10),
              // weight
              Text('${S.of(context).weight}: $weightText',
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10),
              // note
              Text('${S.of(context).diary}: $noteDesc',
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10),
              // tags
              if (tags.isNotEmpty) ...[
                Text('${S.of(context).tag} ${tags.join(', ')}',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text(S.of(context).edit),
                    onPressed: () async {
                       final changeData = await Navigator.of(context).pushNamed(
                        '/add_record',
                        arguments: afterModifyRecord,
                      );
                      
                      setState(() {
                        // 更新顯示的資料   
                        if (changeData != null && changeData is BabyRecord) {
                          dateTime = changeData.date.toString().split(' ')[0];
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
                          afterModifyRecord = changeData; // 更新原始記錄
                        }                    
                       }
                     );
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
