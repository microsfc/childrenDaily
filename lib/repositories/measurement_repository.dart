import 'dart:async';
import '../models/measurement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class MeasurementRepository {
  Future<List<Measurement>> getMeasurements(String userId);
  Future<List<Measurement>> getMeasurementsByDateRange(String userId, DateTime startDate, DateTime endDate);
  Future<List<Measurement>> getMeasurementsByDate(String userId, DateTime date);
  Future<void> addOrUpdateMeasurement(Measurement measurement);
  Future<void> deleteMeasurement(String id);
}

class FirestoreMeasurementRepository implements MeasurementRepository {
  final FirebaseFirestore _firestore;

  FirestoreMeasurementRepository(this._firestore);

  @override
  Future<List<Measurement>> getMeasurements(String userId) async {
    final snapshot = await _firestore
        .collection('height_weight')
        .where('uid', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Measurement.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<Measurement>> getMeasurementsByDateRange(String userId, DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore
        .collection('height_weight')
        .where('uid', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Measurement.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<Measurement>> getMeasurementsByDate(String userId, DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final snapshot = await _firestore
        .collection('height_weight')
        .where('uid', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .get();
    if (snapshot.docs.isEmpty) {
      return [];
    } else {
      return snapshot.docs
        .map((doc) => Measurement.fromMap(doc.data(), doc.id))
        .toList();
    }
  }

  @override
  Future<void> addOrUpdateMeasurement(Measurement measurement) async {
    final measurementData = measurement.toMap();
    final querySnapshot = await _firestore
        .collection('height_weight')
        .where('uid', isEqualTo: measurement.uid)
        .where('date', isEqualTo: measurement.date)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update existing measurement
      final docId = querySnapshot.docs.first.id;
      await _firestore.collection('height_weight').doc(docId).update(measurementData);
    } else {
      // Add new measurement
      await _firestore.collection('height_weight').add(measurementData);
    }
  }
  
  @override
  Future<void> deleteMeasurement(String id) async {
    await _firestore.collection('height_weight').doc(id).delete();
  }
}