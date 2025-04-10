import '../models/baby_record.dart';
import 'package:flutter/material.dart';
import 'package:children/state/AppState.dart';
import 'package:cached_network_image/cached_network_image.dart';



class RecordTile extends StatefulWidget {
  final BabyRecord record;

  const RecordTile({super.key, required this.record});

  @override
  State<RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<RecordTile> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? Colors.blue.shade100 : Colors.white;
    final dateStr = widget.record.date.toLocal().toString().split(' ')[0];
    final noteDesc =
        widget.record.note.isNotEmpty ? 'Description: ${widget.record.note}': '';
    final vaccineText = widget.record.vaccineStatus.isNotEmpty
        ? 'note: ${widget.record.vaccineStatus}'
        : '';
    final heightText = widget.record.height.isNotEmpty
        ? 'Height: ${widget.record.height}'
        : 'No height';
    final weightText = widget.record.weight.isNotEmpty
        ? 'Weight: ${widget.record.weight}'
        : 'No weight';

    return Card(
        color: backgroundColor,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 12.0,
        child: ListTile(
          leading: widget.record.photoUrl.isNotEmpty
              ?
              CachedNetworkImage(imageUrl: widget.record.photoUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  memCacheWidth: 200,
                  errorWidget:(context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover)
               : const Icon(Icons.photo),
          title: Text('$dateStr\n$vaccineText'),
          subtitle: Text('$noteDesc\n$heightText $weightText'),
          trailing: widget.record.tags.isNotEmpty
              ? Text(widget.record.tags.join(', '))
              : const Text('No tags'),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/record_detail',
              arguments: widget.record,
            );
          },
          onLongPress: () {
            setState(() {
              isSelected = !isSelected;
              if (isSelected) {
                AppState.of(context).addSelectedRecordID(widget.record.id);
              } else {
                AppState.of(context).removeSelectedRecordID(widget.record.id);
                isSelected = false;
              }
            });
          },
        ));
  }
}
