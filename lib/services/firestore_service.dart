import '../models/baby_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _babyRecordsCollection =
      FirebaseFirestore.instance.collection('baby_records');

  // 新增或更新 BabyRecord
  Future<void> addOrUpdateRecord(BabyRecord babyRecord) async {
    if (babyRecord.id.isEmpty) {
      // 新增
      await _babyRecordsCollection.add(babyRecord.toMap());
    } else {
      // 更新
      await _babyRecordsCollection
          .doc(babyRecord.id)
          .update(babyRecord.toMap());
    }
  }

  // 刪除 BabyRecord
  Future<void> deleteRecord(String id) async {
    await _babyRecordsCollection.doc(id).delete();
  }

  // (Optional) Delete multiple records in a loop
  Future<void> deleteMultipleRecords(List<String> ids) async {
    // for (var id in ids) {
    //   await deleteRecord(id);
    // }
    // Option B: use a WriteBatch for more efficiency
    final batch = FirebaseFirestore.instance.batch();
    for (var id in ids) {
      batch.delete(_babyRecordsCollection.doc(id));
    }
    await batch.commit();
  }

  Future<Stream<List<BabyRecord>>> getTagsStartingWith(String prefix) async {
    // 資料庫 tags 欄位 index
    return _babyRecordsCollection
        .orderBy('date') // 必須先 orderBy 同一個欄位
        .where('tags', arrayContains: prefix)
        // .where('note', isLessThan: '${prefix}\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // 取得所有 BabyRecord (依日期排序)
  Stream<List<BabyRecord>> getBabyRecords() {
    return _babyRecordsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // batch to fetch records
  Future<QuerySnapshot> getBabyRecordsBatch(
      {required int limit, DocumentSnapshot? lastDocument}) async {
    Query query = _babyRecordsCollection
        .orderBy('date', descending: true);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query
        .limit(limit)
        .get();
    return snapshot;
  }
  // batch with keyword search records
  Future<QuerySnapshot> getBabyRecordsKeyWordBatch(
      {required int limit, DocumentSnapshot? lastDocument, required keyword}) async {
    Query query = _babyRecordsCollection
        .orderBy('date', descending: true)
        .where('tags', arrayContains: keyword);

    final snapshot = await query
        .limit(limit)
        .get();
    return snapshot;
  }
}
