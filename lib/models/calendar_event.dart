import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  String id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  String creatorId;
  List<String> sharedWith; // sharedWith is a list of user IDs shared the calendar event with

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.creatorId,
    this.sharedWith = const [],
  });

  // 從 Firestore 文件資料轉換為 CalendarEvent 物件
  factory CalendarEvent.fromeFirestore(Map<String, dynamic> data, String documentId) {
    return CalendarEvent(
      id: documentId,
      title: data['title'],
      description: data['description'],
      startTime: (data['startTime'].toDate()),
      endTime: (data['endTime'].toDate()),
      creatorId: data['creatorId'],
      sharedWith: List<String>.from(data['sharedWith']),
    );
  }

  // 將 CalendarEvent 物件轉換為 Firestore 文件資料
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'sharedWith': sharedWith,
      'creatorId': creatorId,
    };
  }

  CalendarEvent
  copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? creatorId,
    List<String>? sharedWith,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      creatorId: creatorId ?? this.creatorId,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }


  //isSharedWith checks if the event is shared with a specific user
  bool isSharedWith(String userId) => creatorId == userId || sharedWith.contains(userId);
  String get formattedTimeRange => '${_formatDateTime(startTime)} - ${_formatDateTime(endTime)}';
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  bool isOnSameDay(DateTime date) {
    return startTime.year == date.year &&
           startTime.month == date.month &&
           startTime.day == date.day;
  }
}