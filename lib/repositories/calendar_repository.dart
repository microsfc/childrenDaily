import 'package:rxdart/rxdart.dart';
import '../models/calendar_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CalendarRepository {
  Future<CalendarEvent?> createEvent(CalendarEvent event);
  Future<CalendarEvent> updateEvent(CalendarEvent event);
  Future<bool> deleteEvent(String eventId);
  Future<List<CalendarEvent>> getEvents(String userId);
  Future<CalendarEvent?> getEventsById(String eventId);
  Future<List<CalendarEvent>> getEventsByDate(String userId, DateTime date);
  Stream<List<CalendarEvent>> getEventsStream(String userId);
}

class FirestoreCalendarRepository implements CalendarRepository {
  final FirebaseFirestore _firestore;

  FirestoreCalendarRepository(this._firestore);

  @override
  Future<CalendarEvent?> createEvent(CalendarEvent event) async {
    final eventData = event.toFirestore();
    final docRef = await _firestore.collection('calendar_events').add(eventData);
    return event.copyWith(id: docRef.id);
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final eventData = event.toFirestore();
    await _firestore.collection('calendar_events').doc(event.id).update(eventData);
    return event;
  }

  @override
  Future<bool> deleteEvent(String eventId) async {
    try {
      // Check if the event exists before deleting
      final doc = await _firestore.collection('calendar_events').doc(eventId).get();
      if (!doc.exists) {
        throw Exception('Event not found');
      }
    } catch (e) {
      throw Exception('Error checking event existence: $e');
    }
    await _firestore.collection('calendar_events').doc(eventId).delete();
    return true;
  }

  @override
  Future<List<CalendarEvent>> getEvents(String userId) async {
    // final createdEventsSnapshot = await _firestore
    //     .collection('calendar_events')
    //     .where('creatorId', isEqualTo: userId)
    //     .get();

    // get events shared with the user
    final sharedEventSnapshot = await _firestore
        .collection('calendar_events')
        .where('sharedWith', arrayContains: userId)
        .get();

    // final allEvents = [
    //   ...createdEventsSnapshot.docs.map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id)),
    //   ...sharedEventSnapshot.docs.map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id)),
    // ];

    final allEvents = sharedEventSnapshot.docs
        .map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id))
        .toList();
    // Sort events by start time
    allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allEvents;
  }

  @override
  Future<CalendarEvent?> getEventsById(String eventId) async {
    final doc = await _firestore
        .collection('calendar_events')
        .doc(eventId)
        .get();

    if (doc.exists) {
      return CalendarEvent.fromeFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<List<CalendarEvent>> getEventsByDate(String userId, DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // Get events created by the user on the specified date
    
    final createUserSnapShot = await _firestore
        .collection('calendar_events')
        .where('creatorId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: startDate)
        .where('startTime', isLessThan: endDate)
        .get();
    
    // Get events shared with the user on the specified date
    final sharedUserSnapshot = await _firestore
        .collection('calendar_events')
        .where('sharedWith', arrayContains: userId)
        .where('startTime', isGreaterThanOrEqualTo: startDate)
        .where('startTime', isLessThan: endDate)
        .get();

    final allEventsBySelecteDay = [
      ...createUserSnapShot.docs.map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id)),
      ...sharedUserSnapshot.docs.map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id)),
    ];

    // Sort events by start time
    allEventsBySelecteDay.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allEventsBySelecteDay;
  }

  @override
  Stream<List<CalendarEvent>> getEventsStream(String userId) {
    // // Get events where user is the creator
    // final createdEventsStream = _firestore
    //     .collection('calendar_events')
    //     .where('creatorId', isEqualTo: userId)
    //     .snapshots()
    //     .map((snapshot) => snapshot.docs
    //         .map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id))
    //         .toList());
    // Get events where user is a participant
    final sharedEventsStream = _firestore
        .collection('calendar_events')
        .where('sharedWith', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalendarEvent.fromeFirestore(doc.data(), doc.id))
            .toList());
    return sharedEventsStream;
    // // Combine both streams
    // return createdEventsStream.asyncMap((createdEventsStream) async {
    //   final sharedEvents = await sharedEventsStream.first;
    //   final allEvents = [...createdEventsStream, ...sharedEvents];
    //   // Sort events by start time
    //   allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    //   return allEvents;
    // }); 
  }
}       