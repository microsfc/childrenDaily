import '../models/calendar_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String EVENT_COLLECTION = 'calendar_events';

  // 取得當前用戶 ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // 建立事件
  Future<CalendarEvent?> createEvent(CalendarEvent event) async {
    try {
      if (_auth.currentUser == null) {
        return null;
      }

      DocumentReference eventRef = await _firestore.collection(EVENT_COLLECTION).add(event.toFirestore());
      final snapshot = await eventRef.get();
      return CalendarEvent.fromeFirestore(snapshot.data() as Map<String, dynamic>, snapshot.id);
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  // 讀取事件 (特定月份和年份)
  Stream<List<CalendarEvent>> getEventsForMonthYear(int month, int year) {
    final startOfTheMonth = DateTime(year, month, 1, 0, 0, 0);
    final endOfTheMonth = DateTime(year, month + 1, 1, 0, 0, 0).subtract(Duration(milliseconds: 1));
    
    return _firestore
        .collection(EVENT_COLLECTION)
        .where('startTime', isGreaterThanOrEqualTo: startOfTheMonth)
        .where('endTime', isLessThan: endOfTheMonth)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id))
            .toList());
  }

  // 讀取所有事件
  Stream<List<CalendarEvent>> getAllEventsWithSharedUser() {
    
    return _firestore
        .collection(EVENT_COLLECTION)
        .where('sharedWith', arrayContains: getCurrentUserId())
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
            return snapshot.docs
            .map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id))
            .toList();
        });
  }

  // 更新事件
  Future<CalendarEvent?> updateEvent(CalendarEvent event) async {
    try {
      await _firestore
            .collection(EVENT_COLLECTION)
            .doc(event.id)
            .update(event.toFirestore());
      DocumentSnapshot snapshot = await _firestore
                                        .collection(EVENT_COLLECTION)
                                        .doc(event.id).get();
      return CalendarEvent
             .fromeFirestore(snapshot.data() as Map<String, dynamic>, snapshot.id); 
    } catch (e) {
      print('Error updating event: $e');
      return null;
    }
  }

  // 刪除事件
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(EVENT_COLLECTION).doc(eventId).delete();
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  // 事件共享 (添加共享用戶)
Future<CalendarEvent?> shareEvent(String eventId, List<String>userIdToShare) async {
    try {
      DocumentReference eventRef = _firestore.collection(EVENT_COLLECTION).doc(eventId);
      DocumentSnapshot eventSnapshot = await eventRef.get();
      if (!eventSnapshot.exists) {
        print('$eventId  does not exist');
        return null;
      }

      CalendarEvent event = CalendarEvent.fromeFirestore(eventSnapshot.data() as Map<String, dynamic>, eventSnapshot.id);
      List<String> updateShareWith =  [...event.sharedWith, ...userIdToShare];
      await eventRef.update({'sharedWith': updateShareWith});
      DocumentSnapshot updateSnapshot = await eventRef.get();
      return CalendarEvent.fromeFirestore(updateSnapshot.data() as Map<String, dynamic>, updateSnapshot.id);
    } catch (e) {
      print('Error sharing event: $e');
      return null;
    }
  }

  // 事件共享 (移除共享用戶)
  Future<CalendarEvent?> unshareEvent(String eventId, List<String>userIdToUnshare) async {
    try {
      DocumentReference eventRef = _firestore.collection(EVENT_COLLECTION).doc(eventId);
      DocumentSnapshot eventSnapshot = await eventRef.get();
      if (!eventSnapshot.exists) {
        print('$eventId  does not exist');
        return null;
      }
      CalendarEvent event = CalendarEvent.fromeFirestore(eventSnapshot.data() as Map<String, dynamic>, eventSnapshot.id);
      List<String> updateSharedWith = event.sharedWith.where((userId) => !userIdToUnshare.contains(userId)).toList();
      await eventRef.update({'sharedWith': updateSharedWith});
      DocumentSnapshot updateSnapshot = await eventRef.get();
      return CalendarEvent.fromeFirestore(updateSnapshot.data() as Map<String, dynamic>, updateSnapshot.id);
    } catch (e) {
      print('Error unsharing event: $e');
      return null;
    }
  }

  // (進階功能) 監聽共享給特定用戶的事件 (例如：當前用戶)
  Stream<List<CalendarEvent>> getEventsSharedWithUser(String userId) {
    return _firestore
        .collection(EVENT_COLLECTION)
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id))
            .toList());
  }






}