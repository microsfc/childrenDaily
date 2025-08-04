import 'package:cloud_firestore/cloud_firestore.dart';

class BabyRecord {
  final String id; // Firestore 文件的 id
  final String uid; // 使用者的 id
  final DateTime date; // 日期
  final String photoUrl; // 照片的 URL
  final String note; // 紀錄的文字
  final String vaccineStatus; // 疫苗狀態
  final List<String> tags; // 標籤
  final String height; // 身高
  final String weight; // 體重
  final List<String> sharedIds;
  final String emoji = ''; // 表情符號，預設為空字符串

  BabyRecord({
    required this.id,
    required this.uid,
    required this.date,
    required this.photoUrl,
    required this.note,
    required this.tags,
    required this.vaccineStatus,
    required this.height,
    required this.weight,
    required this.sharedIds,
    emoji = "❤️",
  });

  // 將 Firebase 讀出的資料轉成 Model
  factory BabyRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return BabyRecord(
      id: documentId,
      uid: map['uid'] as String,
      date: (map['date'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'] as String? ?? '',
      note: map['note'] as String? ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      vaccineStatus: map['vaccineStatus'] as String? ?? '',
      height: map['height'] as String? ?? '',
      weight: map['weight'] as String? ?? '',
      sharedIds: List<String>.from(map['sharedIds'] ?? []),
    );
  }

  // 將 Model 轉成可以存入 Firestore 的 Map
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'uid': uid,
      'photoUrl': photoUrl,
      'note': note,
      'tags': tags,
      'vaccineStatus': vaccineStatus,
      'height': height,
      'weight': weight,
      'sharedIds': sharedIds,
    };
  }

  // Create a copy of the current instance with new values
  BabyRecord copyWith({
    String? id,
    String? uid,
    DateTime? date,
    String? photoUrl,
    String? note,
    List<String>? tags,
    String? vaccineStatus,
    String? height,
    String? weight,
    List<String>? sharedIds,
  }) {
    return BabyRecord(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      date: date ?? this.date,
      photoUrl: photoUrl ?? this.photoUrl,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      vaccineStatus: vaccineStatus ?? this.vaccineStatus,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      sharedIds: sharedIds ?? this.sharedIds,
    );
  }

  // Helper function for formatted data
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  bool get hasPhoto => photoUrl.isNotEmpty;
  bool get hasNote => note.isNotEmpty;
  bool get hasTags => tags.isNotEmpty;
  bool get hasVaccineStatus => vaccineStatus.isNotEmpty;
  bool get hasHeight => height.isNotEmpty;
  bool get hasWeight => weight.isNotEmpty;
  bool get hasSharedIds => sharedIds.isNotEmpty;
  String get formattedTags => tags.join(', ');
}
