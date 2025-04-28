import '../models/baby_record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:children/bloc/record_event.dart';
import 'package:children/bloc/record_state.dart';
import 'package:children/models/baby_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:children/services/firestore_service.dart';


class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final FirestoreService firestoreService;
  DocumentSnapshot ?_lastDocument;

  RecordBloc({required this.firestoreService}) : super(RecordInitial()) {
    on<LoadRecordEvent>((event, emit) async {
      await _onLoadRecordEvent(event, emit);
    });
    on<AddOrUpdateRecordEvent>((event, emit) async {
      await _onAddOrUpdateRecordEvent(event, emit);
    });
    on<DeleteRecordEvent>((event, emit) async {
      await _onDeleteRecordEvent(event, emit);
    });
    on<ExitPageEvent>((event, emit) async {
      await _onExitPageEvent(event, emit);
    });
  }

  Future<void> _onExitPageEvent(
      ExitPageEvent event, Emitter<RecordState> emit) async {
    emit(RecordInitial());
  }
  Future<void> _onDeleteRecordEvent(
      DeleteRecordEvent event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    try {
      await firestoreService.deleteRecord(event.recordId);
      add(LoadRecordEvent(event.userId!, false, null));
    } catch (e) {
      emit(RecordError(e.toString()));
    }
  }

  Future <void> _onLoadRecordEvent(
      LoadRecordEvent event, Emitter<RecordState> emit) async {
    emit(RecordLoading());
    final QuerySnapshot<Object?> records;
    try {
      // 取得資料
      if (event.loadByKeyWord) {
        records = await firestoreService.getBabyRecordsKeyWordBatch(
            limit: 5,
            lastDocument: _lastDocument,
            uid: event.uid,
            keyword: event.keyword);    
      } else {
        records = await firestoreService.getBabyRecordsBatch(limit: 5, lastDocument: _lastDocument, uid: event.uid);
      }
      if (records.docs.isNotEmpty) {
        // Update _lastDocument to the last doc from this batch
        _lastDocument = records.docs.last;
        // Convert each doc to your model (BabyRecord)
        final List<BabyRecord> babyRecords = records.docs
            .map((doc) => BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        emit(RecordLoaded(babyRecords));
      } else {
        _lastDocument = null;
        emit(RecordLoadFinish());
      }
    } catch (e) {
      emit(RecordError(e.toString()));
    }}

    Future<void> _onAddOrUpdateRecordEvent(
        AddOrUpdateRecordEvent event, Emitter<RecordState> emit) async {
      emit(RecordLoading());
      try {
        await firestoreService.addOrUpdateRecord(event.record);
        add(LoadRecordEvent(event.record.uid, false, null));
      } catch (e) {
        emit(RecordError(e.toString()));
      }
    }
}