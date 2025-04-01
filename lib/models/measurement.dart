class Measurement {
  final String id;
  final String uid;
  final DateTime date;
  final double height; // 身高 (cm)
  final double weight; // 體重 (kg)
  Measurement({required this.id, required this.uid, required this.date, required this.height, required this.weight});

  factory Measurement.fromMap(Map<String, dynamic> map, String documentId) {
    return Measurement(
      id: documentId,
      uid: map['uid'],
      date: (map['date'].toDate()),
      height: map['height'],
      weight: map['weight'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': date,
      'height': height,
      'weight': weight,
    };
  }
}