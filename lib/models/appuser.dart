import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String profileImageUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.profileImageUrl,});

  factory AppUser.fromMap(Map<String, dynamic> map, String userId) {
    return AppUser(
      uid: map['uid'] as String? ?? userId,
      email: map['email'] as String? ?? 'No Email',
      displayName: map['displayName'] as String? ?? 'No Name',
      profileImageUrl: map['profileImageUrl'] as String? ?? 'No Image',
    );
    // print('Raw Firestore Data: $map');  
    // final user = AppUser(
    //   uid: map['uid'] as String? ?? userId,
    //   email: map['email'] as String? ?? 'No Email',
    //   displayName: map['displayName'] as String? ?? 'No Name',
    // );
    // print('Mapped User: ${user.uid}, ${user.email}, ${user.displayName}');  
    // final user2 = AppUser(
    //   uid: userId,
    //   email: map['email'] as String? ?? 'No Email',
    //   displayName: map['displayName'] as String? ?? 'No Name',
    // );
    // print('Mapped User2: ${user2.uid}, ${user2.email}, ${user2.displayName}');  
    // return user;
  }

   Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
    };
   }
}
