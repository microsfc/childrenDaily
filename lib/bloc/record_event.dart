import 'package:children/models/appuser.dart';
import 'package:children/models/baby_record.dart';

abstract  class RecordEvent {}

class LoadRecordEvent extends RecordEvent {
  final String uid;
  bool loadByKeyWord = false;
  String? keyword;
  LoadRecordEvent(this.uid, this.loadByKeyWord, this.keyword);
}

class AddOrUpdateRecordEvent extends RecordEvent {
  final BabyRecord record;
  AddOrUpdateRecordEvent(this.record);
}

class DeleteRecordEvent extends RecordEvent {
  final String recordId;
  final String? userId;
  DeleteRecordEvent(this.recordId, this.userId);
}

class ExitPageEvent extends RecordEvent {
  final String uid;
  ExitPageEvent(this.uid);
}