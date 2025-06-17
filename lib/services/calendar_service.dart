import '../models/calendar_event.dart';
import '../repositories/calendar_repository.dart';

abstract class CalendarService {
  Future<List<CalendarEvent>> getAllEvents(String userId);
  Future<List<CalendarEvent>> getEventsForDate(String userId, DateTime date);
  Future<CalendarEvent?> createEvent(CalendarEvent event);
  Future<CalendarEvent?> updateEvent(CalendarEvent event);
  Future<bool> deleteEvent(String eventId);
  Stream<List<CalendarEvent>> getAllEventsWithSharedUser();
  String? getCurrentUserId();
}

class CalendarServiceImpl implements CalendarService {
  final CalendarRepository _repository;
  
  CalendarServiceImpl(this._repository);
  
  @override
  Future<List<CalendarEvent>> getAllEvents(String userId) async {
    return await _repository.getEvents(userId);
  }
  
  @override
  Future<List<CalendarEvent>> getEventsForDate(String userId, DateTime date) async {
    return await _repository.getEventsByDate(userId, date);
  }
  
  @override
  Future<CalendarEvent?> createEvent(CalendarEvent event) async {
    try {
      return await _repository.createEvent(event);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<CalendarEvent?> updateEvent(CalendarEvent event) async {
    try {
      return await _repository.updateEvent(event);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> deleteEvent(String eventId) async {
    return await _repository.deleteEvent(eventId);
  }
  
  @override
  Stream<List<CalendarEvent>> getAllEventsWithSharedUser() {
    final userId = getCurrentUserId();
    if (userId == null) {
      // Return empty stream if no user is logged in
      return Stream.value([]);
    }
    
    return _repository.getEventsStream(userId);
  }
  
  @override
  String? getCurrentUserId() {
    // This would normally come from your AuthService
    // For now, we'll return null
    return null;
  }
}