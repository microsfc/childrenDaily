import '../models/baby_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BabyRecordRepository {
  Future<List<BabyRecord>> getRecords(String userId);
  Future<List<BabyRecord>> getRecordsByDate(String userId, DateTime date);
  Future<List<BabyRecord>> getRecordsBatch({required String uid, int limit = 10, DocumentSnapshot? lastDocument});
  Future<List<BabyRecord>> searchRecords(String userId, String keyword);
  Future<BabyRecord?> getRecordById(String id);
  Future<BabyRecord> addOrUpdateRecord(BabyRecord record);
  Future<void> deleteRecord(String id);
  Future<void> deleteMultipleRecords(List<String> ids);
  Stream<List<BabyRecord>> streamRecords(String userId);
}

class FirestoreBabyRecordRepository implements BabyRecordRepository {
  final FirebaseFirestore _firestore;
  
  FirestoreBabyRecordRepository(this._firestore);
  
  @override
  Future<List<BabyRecord>> getRecords(String userId) async {
    final snapshot = await _firestore.collection('baby_records')
        .where('uid', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => BabyRecord.fromMap(doc.data(), doc.id))
        .toList();
  }
  
  @override
  Future<List<BabyRecord>> getRecordsBatch({
    required String uid, 
    int limit = 10, 
    DocumentSnapshot? lastDocument
  }) async {
    Query query = _firestore.collection('baby_records')
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(limit);
        
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    
    try {
     final snapshot = await query.get();
    return snapshot.docs
      .map((doc) => BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .toList();
    } catch (e, stack) {
      print('🔥 Firestore query error: $e');
      print(stack);
      return [];
    }
  }
  
  @override
  Future<List<BabyRecord>> searchRecords(String userId, String keyword) async {
    // First search by tags that contain the keyword
    final tagsSnapshot = await _firestore.collection('baby_records')
        .where('uid', isEqualTo: userId)
        .where('tags', arrayContains: keyword)
        .get();
        
    // Then search by note field
    final noteSnapshot = await _firestore.collection('baby_records')
        .where('uid', isEqualTo: userId)
        .get();
    
    // Filter note results manually since Firestore doesn't support text search
    final noteResults = noteSnapshot.docs
        .where((doc) => (doc.data()['note'] as String).toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    
    // Combine results and remove duplicates
    final allDocs = [...tagsSnapshot.docs, ...noteResults];
    final uniqueIds = <String>{};
    final uniqueDocs = <QueryDocumentSnapshot>[];
    
    for (final doc in allDocs) {
      if (!uniqueIds.contains(doc.id)) {
        uniqueIds.add(doc.id);
        uniqueDocs.add(doc);
      }
    }
    
    return uniqueDocs
        .map((doc) => BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
  
  @override
  Future<BabyRecord?> getRecordById(String id) async {
    final doc = await _firestore.collection('baby_records').doc(id).get();
    if (!doc.exists) return null;
    
    return BabyRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
  
  @override
  Future<BabyRecord> addOrUpdateRecord(BabyRecord record) async {
    final recordData = record.toMap();
    
    if (record.id.isEmpty) {
      // Create new record
      final docRef = await _firestore.collection('baby_records').add(recordData);
      return record.copyWith(id: docRef.id);
    } else {
      // Update existing record
      await _firestore.collection('baby_records').doc(record.id).update(recordData);
      return record;
    }
  }
  
  @override
  Future<void> deleteRecord(String id) async {
    await _firestore.collection('baby_records').doc(id).delete();
  }
  
  @override
  Future<void> deleteMultipleRecords(List<String> ids) async {
    // Create a batched write
    final batch = _firestore.batch();
    
    for (final id in ids) {
      final docRef = _firestore.collection('baby_records').doc(id);
      batch.delete(docRef);
    }
    
    await batch.commit();
  }
  
  @override
  Future<List<BabyRecord>> getRecordsByDate(String userId, DateTime date) async {
    // Create start and end dates for the given day
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final snapshot = await _firestore.collection('baby_records')
        .where('uid', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();
        
    return snapshot.docs
        .map((doc) => BabyRecord.fromMap(doc.data(), doc.id))
        .toList();
  }
  
  @override
  Stream<List<BabyRecord>> streamRecords(String userId) {
    return _firestore.collection('baby_records')
        .where('uid', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BabyRecord.fromMap(doc.data(), doc.id))
            .toList());
  }
}