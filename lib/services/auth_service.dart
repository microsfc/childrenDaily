import 'dart:io';
import '../di/locator.dart';
import '../models/appuser.dart';
import '../repositories/user_repository.dart';
import 'package:children/state/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:children/services/storage_service.dart';
import 'package:children/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


abstract class AuthService {
  Future<AppUser?> signInWithEmailAndPassword(String email, String password);
  Future<AppUser?> signUpWithEmailAndPassword(String email, String password, String displayName, File? profileImageUrl);
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
  User? getCurrentUser();
  Stream<User?> get authStateChanges; 
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final UserRepository _userRepository;
  late final authState = AuthState(locator<AuthService>(), locator<UserRepository>());

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('uid');
  }
  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  FirebaseAuthService(this._userRepository);

  @override
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (userCredential.user != null) { 
        prefs.setString('email', userCredential.user!.email!);
        prefs.setString('uid', userCredential.user!.uid);
        authState.setUid(userCredential.user!.uid);
        return await _userRepository.getUserById(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code}');
      // ErrorDialog(errorMessage: 'Error signing in with email and password');
      return null;
    }
    return null;
  }
  @override
  Future<AppUser?> signUpWithEmailAndPassword(String email, String password, String displayName, File? profileImageUrl) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (userCredential.user != null) { 
        prefs.setString('email', userCredential.user!.email!);
        prefs.setString('uid', userCredential.user!.uid);
        String imageUrl = '';
        if (profileImageUrl != null) {
          // Use a concrete implementation of StorageService
          final storageService = FirebaseStorageService(FirebaseStorage.instance);
          imageUrl = await storageService.uploadProfileImage(profileImageUrl, userCredential.user!.uid);
        }
        authState.setUid(userCredential.user!.uid);
        await FirestoreService().addUser(AppUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: displayName,
          profileImageUrl: imageUrl,
          fcmToken: await _messaging.getToken() ?? '',
        ));
        authState.setUser(AppUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: displayName,
          profileImageUrl: imageUrl,
          fcmToken: await _messaging.getToken() ?? '',
        ));
      }
      return await _userRepository.getUserById(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code}');
      // ErrorDialog(errorMessage: 'Error signing in with email and password');
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // 1) 跟 Google Sign-In SDK 要求使用者選擇 Google 帳號
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // 2) 取得 Google 帳號的資料
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // 3) 使用 Google 帳號的資料建立 GoogleAuthCredential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4) 使用 GoogleAuthCredential 登入 Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', userCredential.user!.email!);
      prefs.setString('uid', userCredential.user!.uid);
      authState.setUid(userCredential.user!.uid);
      // 從Firestore獲取用戶詳細信息
      final QuerySnapshot<Object?> recordsSnapshot;
      
      recordsSnapshot = await FirestoreService().getUser(userCredential.user!.uid);
      final List<AppUser> user = recordsSnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>, userCredential.user!.uid))
          .toList();
      if (user.isNotEmpty) {
        authState.setUser(user[0]);
      } else {
        // 如果用戶不存在，則創建新用戶
        // 登錄成功後，獲取FCM令牌
        String? token = await _messaging.getToken();
        await FirestoreService().addUser(AppUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName!,
          profileImageUrl: userCredential.user!.photoURL!,
          fcmToken: token!,
        ));
      }
      return await _userRepository.getUserById(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code}');
      // ErrorDialog(errorMessage: 'Error signing in with Google');
      return null;
    } catch (e) {
      // ErrorDialog(errorMessage: 'Error signing in with Google = ${e.toString()}');
      print('Sign in error: $e');
      return null;
    }
   }
  }