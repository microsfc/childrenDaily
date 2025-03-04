//event.dart

class Event {
  String? id;
  String title ='';
  DateTime date = DateTime.now();
  String? description;
  String? createId;

  Event({required this.title, required this.date, this.id, this.description, this.createId});

  @override
  String toString() => title;
}