import 'package:children/models/baby_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ref<T> {
  T value;
  Ref(this.value);
}


class RecordsBatch {
  final List<BabyRecord> records;
  final DocumentSnapshot? lastDocument;
  
  RecordsBatch({required this.records, this.lastDocument});
}