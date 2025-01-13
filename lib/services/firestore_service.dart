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
      } else  {
        // 更新
        await _babyRecordsCollection.doc(babyRecord.id).update(babyRecord.toMap());
      }
      
    }

    // 刪除 BabyRecord
    Future<void> deleteRecord(String id) async {
      await _babyRecordsCollection.doc(id).delete();
    }

    // 取得所有 BabyRecord (依日期排序)
    Stream<List<BabyRecord>> getBabyRecords() {
      return _babyRecordsCollection.orderBy('date', descending: true).snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      });
    }

}