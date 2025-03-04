import '../models/event.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // 導入 Timer 用於簡單的同步
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 導入 FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // 導入 Firestore

class CalendarProvider extends ChangeNotifier {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  // *** 新增 Firebase 相關變數 ***
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _calendarId = '';
  StreamSubscription<QuerySnapshot>? _eventsSubscription; // 用於監聽事件變化


  CalendarProvider() {
    _selectedDay = _focusedDay;
    _loadEventsForSelectedCalendar(); // 初始化時載入預設行事曆事件
  }

  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  Map<DateTime, List<Event>> get events => _events;
  String get calendarId => _calendarId;

   // *** 新增設定行事曆 ID 的方法 ***
  void setCalendarId(String calendarId) {
    _calendarId = calendarId;
    _loadEventsForSelectedCalendar(); // 切換行事曆時重新載入事件
    notifyListeners();
  }

  void setCalenderFormat(CalendarFormat format) {
    _calendarFormat = format;
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  } 

  List<Event> getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  // *** 修改 addEvent 方法，改為儲存到 Firestore ***
  Future<void> addEvent(Event event) async {
    try {
      final normalizedDate = DateTime(event.date.year, event.date.month, event.date.day);
      await _firestore.collection('calendars')
                      .doc(_calendarId)
                      .collection('events').add({
                        'title': event.title,
                        'date': normalizedDate,
                        'description': event.description,
                        'createId': _auth.currentUser!.uid,
                        'createdAt': FieldValue.serverTimestamp()
                      });
      // Firestore 的即時監聽會自動更新 _events，不需要手動更新
      ScaffoldMessenger.of(null as BuildContext).showSnackBar(
        SnackBar(content: Text('新增事件失敗')),
      );
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  // *** 新增 _loadEventsForSelectedCalendar 方法，從 Firestore 讀取事件並即時監聽 ***
  void _loadEventsForSelectedCalendar() {
    _eventsSubscription?.cancel(); // 取消之前的監聽
    _eventsSubscription = _firestore.collection('calendars')
                                     .doc(_calendarId)
                                     .collection('events')
                                     .orderBy('date')
                                     .snapshots()
                                     .listen((snapshot) {
       Map<DateTime, List<Event>> fetchEvents = {};

      for (final doc in snapshot.docs) {
        final eventData = doc.data();
        DateTime eventDate = (eventData['date'] as Timestamp).toDate();
        DateTime normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
        final event = Event(
          id: doc.id,
          title: eventData['title'],
          date: normalizedDate,
          description: eventData['description'],
          createId: eventData['createId'],
        );

        if (fetchEvents[normalizedDate] == null) {
          fetchEvents[normalizedDate] = [event];
        } else {
          fetchEvents[normalizedDate]!.add(event);
        }
      }
      _events = fetchEvents;
      notifyListeners();
    }, onError: (error) {
      print('Error loading events: $error');
      ScaffoldMessenger.of(null as BuildContext).showSnackBar(
        SnackBar(content: Text('載入事件失敗')),
      );  
    });
  }

  // *** 新增 updateEvent 方法，更新 Firestore 中的事件 ***
  Future<void> updateEvent(Event event) async {
    try {
      final normalizedDate = DateTime(event.date.year, event.date.month, event.date.day);
      await _firestore.collection('calendars')
                      .doc(_calendarId)
                      .collection('events')
                      .doc(event.id)
                      .update({
                        'title': event.title,
                        'date': normalizedDate,
                        'description': event.description,
                        'createId': _auth.currentUser!.uid,
                        'updatedAt': FieldValue.serverTimestamp()
                      });
      // Firestore 的即時監聽會自動更新 _events，不需要手動更新
    } catch (e) {
      print('Error updating event: $e');
      ScaffoldMessenger.of(null as BuildContext).showSnackBar(
        SnackBar(content: Text('更新事件失敗')),
      );  
    }
  }
  // *** 新增 deleteEvent 方法，刪除 Firestore 中的事件 ***
  Future<void> deleteEvent(Event event) async {
    try {
      await _firestore.collection('calendars')
                      .doc(_calendarId)
                      .collection('events')
                      .doc(event.id)
                      .delete();
      // Firestore 的即時監聽會自動更新 _events，不需要手動更新
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(null as BuildContext).showSnackBar(
        SnackBar(content: Text('刪除事件失敗')),
      );  
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel(); // 關閉監聽
    super.dispose();
  } 



} 