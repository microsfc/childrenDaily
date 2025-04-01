class RecordDetail {
  DateTime dateTime;
  String photoUrl;
  String note;
  List<String> tags = [];
  List<String> sharedIds = [];
  String vaccineStatus;
  String height;
  String weight;

  RecordDetail({
    required this.dateTime,
    required this.photoUrl,
    required this.note,
    required this.tags,
    required this.vaccineStatus,
    required this.height,
    required this.weight,
    required this.sharedIds,
  });
}