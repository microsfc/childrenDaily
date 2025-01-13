import '../models/baby_record.dart';
import 'package:flutter/material.dart';

class RecordTile extends StatelessWidget {
  final BabyRecord record;

  const RecordTile({
    Key? key,
    required this.record,
  }) : super(key: key);

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

    return Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 12.0,
        child: ListTile(
          leading: record.photoUrl.isNotEmpty
              ? Image.network(record.photoUrl,
                  width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.photo),
          title: Text('$dateStr\n$vaccineText'),
          subtitle: Text('$noteDesc\n$heightText $weightText'),
          trailing: record.tags.isNotEmpty
              ? Text(record.tags.join(', '))
              : const Text('No tags'),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/record_detail',
              arguments: record,
            );
          },
        ));
  }
}
