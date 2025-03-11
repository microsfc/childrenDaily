import '../models/appuser.dart';
import '../models/baby_record.dart';
import '../models/measurement.dart';
import 'package:children/state/AppState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class FirestoreService {
  final CollectionReference _babyRecordsCollection =
      FirebaseFirestore.instance.collection('baby_records');
  final CollectionReference _heightWeightCollection =
      FirebaseFirestore.instance.collection('height_weight');
      
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // 新增或更新使用者
  Future<void> addOrUpdateUser(AppUser user) async {
    await _usersCollection.add(user.toMap());
    // if (user.uid.isEmpty) {
    //   // 新增
    //   await _usersCollection.add(user.toMap());
    // } else {
    //   // 更新
    //   await _usersCollection.doc(user.uid).update(user.toMap());
    // }
  }
    
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

  // 新增或更新身高體重
  Future<void> addOrUpdateHeightWeight(Measurement heightWeightMes) async {

    if (heightWeightMes.id.isEmpty) {
      // 新增
      await _heightWeightCollection.add(heightWeightMes.toMap()); 
    } else {
      // 更新
      await _heightWeightCollection
          .doc(heightWeightMes.id)
          .update(heightWeightMes.toMap());
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

  Future<Stream<List<BabyRecord>>> getTagsStartingWith(String prefix, String uid) async {
    // 資料庫 tags 欄位 index
    return _babyRecordsCollection
        .where('uid', isEqualTo: uid)
        .where('tags', arrayContains: prefix)
        .orderBy('date') // 必須先 orderBy 同一個欄位
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // 取得所有 BabyRecord (依日期排序)
  Stream<List<BabyRecord>> getBabyRecords(String uid) {
    return _babyRecordsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // 取得所有 Measurement (依日期排序)
  Future<List<Measurement>> getHeightWeight(String uid) async {
    final snapshot = await _heightWeightCollection
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();
  
    return snapshot.docs
        .map((doc) =>
            Measurement.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // 取得使用者
  Future<QuerySnapshot> getUser(String uid) async {
      Query query = _usersCollection
        .where('uid', isEqualTo: uid);
        // .orderBy('date', descending: true);

    final snapshot = await query
        .limit(1)
        .get();
    return snapshot;
  }

  // batch with keyword search records
  Future<QuerySnapshot> getBabyRecordsKeyWordBatch(
      {required int limit, DocumentSnapshot? lastDocument, required keyword, required uid}) async {
    Query query = _babyRecordsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .where('tags', arrayContains: keyword);

    final snapshot = await query
        .limit(limit)
        .get();
    return snapshot;
  }
  
  // batch to fetch records
  Future<QuerySnapshot> getBabyRecordsBatch(
      {required int limit, DocumentSnapshot? lastDocument, required String uid}) async {
    Query query = _babyRecordsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query
        .limit(limit)
        .get();
    return snapshot;
  }
}
