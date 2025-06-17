import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/calendar_service.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class CalendarState extends ChangeNotifier {
  final CalendarService _calendarService;
  List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  CalendarState(this._calendarService);

  // Getters
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CalendarEvent> get events => _events;
  bool get hasEvents => _events.isNotEmpty;

  // Setters
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  void setEvents(List<CalendarEvent> events) {
    _events = events;
    notifyListeners();
  }

  List<CalendarEvent> getEventsForDay(DateTime date) {
    return _events.where((event) =>
      event.startTime.year == date.year &&
      event.startTime.month == date.month &&
      event.startTime.day == date.day
    ).toList();
  }

  Future<void> loadEvents(String userId) async {
    setLoading(true);
    setError(null);
    notifyListeners();
    try {
      _events = await _calendarService.getAllEvents(userId);
      setEvents(events);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // loadEventsForDate
  Future<void> loadEventsForDate(String userId, DateTime date) async {
    setLoading(true);
    setError(null);
    notifyListeners();
    try {
      _events = await _calendarService.getEventsForDate(userId, date);
      setEvents(events);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<CalendarEvent?> updateEvent(CalendarEvent event) async {
    setLoading(true);
    setError(null);
    notifyListeners();

    try {
      final updatedEvent = await _calendarService.updateEvent(event);
      if (updatedEvent != null) {
        // Update the local events list
        final index = _events.indexWhere((e) => e.id == updatedEvent.id);
        if (index != -1) {
          _events[index] = updatedEvent;
          setEvents(_events);
        }
      }
      return updatedEvent;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    setLoading(true);
    setError(null);
    notifyListeners();

    try {
      final success = await _calendarService.deleteEvent(eventId);
      if (success) {
        // Remove the event from the local list
        _events.removeWhere((event) => event.id == eventId);
        setEvents(_events);
      }
      return success;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

}
