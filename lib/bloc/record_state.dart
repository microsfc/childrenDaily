import 'package:children/models/baby_record.dart';

class RecordState {}

class RecordInitial extends RecordState {}
class RecordLoading extends RecordState {}
class RecordLoadFinish extends RecordState {}
class RecordLoaded extends RecordState {
  final List<BabyRecord> records;
  RecordLoaded(this.records);
}
class RecordError extends RecordState {
  final String error;
  RecordError(this.error);
}