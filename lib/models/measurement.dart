class Measurement {
  final String id;
  final DateTime date;
  final double height; // 身高 (cm)
  final double weight; // 體重 (kg)
  Measurement({required this.id, required this.date, required this.height, required this.weight});

  factory Measurement.fromMap(Map<String, dynamic> map, String documentId) {
    return Measurement(
      id: documentId,
      date: (map['date'].toDate()),
      height: map['height'],
      weight: map['weight'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'height': height,
      'weight': weight,
    };
  }
}