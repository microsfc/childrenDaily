import '../models/appuser.dart';
import 'package:children/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class UserRepository {
  Future<AppUser?> getUserById(String id);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<List<AppUser>> getAllUsers();
  Future<void> deleteUser(String id);
  Future<void> updateFCMToken(String userId, String fcmToken);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository(this._firestore);

  @override
  Future<AppUser?> getUserById(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('uid', isEqualTo: userId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return AppUser.fromMap(querySnapshot.docs.first.data(), querySnapshot.docs.first.id);
    }
    return null;
  }

  @override
  Future<void> createUser(AppUser user) async {
    final userData = user.toMap();
    await _firestore.collection('users').add(userData); 
  }

  @override
  Future<void> updateUser(AppUser user) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final userId = querySnapshot.docs.first.id;
      await _firestore.collection('users').doc(userId).update(user.toMap());
    } else {
      // 如果用戶不存在，則創建新用戶
      await createUser(user);
    }
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> deleteUser(String id) async {
    await _firestore.collection('users').doc(id).delete();
  }
  
  @override
  Future<void> updateFCMToken(String userId, String fcmToken) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('uid', isEqualTo: userId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final userId = querySnapshot.docs.first.id;
      await _firestore.collection('users').doc(userId).update({'fcmToken': fcmToken});
    } else {
      throw Exception(S.current.noRecordFound);
    }
  }
}
