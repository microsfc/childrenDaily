import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple user model
class User {
  final String uid;
  final String displayName;

  User({required this.uid, required this.displayName});

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: data['uid'] as String,
      displayName: (data['displayName'] ?? '') as String,
    );
  }
}