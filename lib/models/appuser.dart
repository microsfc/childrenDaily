import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String profileImageUrl;
  String fcmToken;
  String errorMessage;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.profileImageUrl,
    required this.fcmToken,
    this.errorMessage = '',
    });

  factory AppUser.fromMap(Map<String, dynamic> map, String userId) {
    return AppUser(
      uid: map['uid'] as String? ?? userId,
      email: map['email'] as String? ?? 'No Email',
      displayName: map['displayName'] as String? ?? 'No Name',
      profileImageUrl: map['profileImageUrl'] as String? ?? 'No Image',
      fcmToken: map['fcmToken'] as String ?? 'No Token',
    );
  }

   Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'fcmToken': fcmToken,
    };
   }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? fcmToken,
  }) {

    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  bool get hasProfileImage {
    return profileImageUrl.isNotEmpty;
  }

  String get initials {
    if (displayName.isEmpty) return '';
    final parts = displayName.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}';
    } else if (parts.isNotEmpty) {
      return parts.first[0];
    }
    return '';
  }

}