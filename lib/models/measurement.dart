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

  Measurement copyWith({
    String? id,
    String? uid,
    DateTime? date,
    double? height,
    double? weight,
  }) {
    return Measurement(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      date: date ?? this.date,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  String get formattedDate => '${date.year}/${date.month}/${date.day}';
  String get formattedHeight => height.toStringAsFixed(1);
  String get formattedWeight => weight.toStringAsFixed(1);
  
  bool get isValid => height > 0 && weight > 0;
  
  // Calculate BMI (for children over 2 years)
  double? get bmi {
    // Height needs to be in meters for BMI calculation
    if (height <= 0) return null;
    return weight / ((height / 100) * (height / 100));
  }
  
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }
}