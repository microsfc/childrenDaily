import 'package:cloud_firestore/cloud_firestore.dart';

class BabyRecord {
  final String id; // Firestore 文件的 id
  final DateTime date; // 日期
  final String photoUrl; // 照片的 URL
  final String note; // 紀錄的文字
  final String vaccineStatus; // 疫苗狀態
  final List<String> tags; // 標籤
  final String height; // 身高
  final String weight; // 體重

  BabyRecord({
    required this.id,
    required this.date,
    required this.photoUrl,
    required this.note,
    required this.tags,
    required this.vaccineStatus,
    required this.height,
    required this.weight,
  });

  // 將 Firebase 讀出的資料轉成 Model
  factory BabyRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return BabyRecord(
      id: documentId,
      date: (map['date'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'],
      note: map['note'],
      tags: List<String>.from(map['tags']),
      vaccineStatus: map['vaccineStatus'],
      height: map['height'],
      weight: map['weight'],
    );
  }

  // 將 Model 轉成可以存入 Firestore 的 Map
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'photoUrl': photoUrl,
      'note': note,
      'tags': tags,
      'vaccineStatus': vaccineStatus,
      'height': height,
      'weight': weight,
    };
  }
}
