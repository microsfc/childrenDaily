import 'dart:io';
import 'package:children/models/appuser.dart';
import 'package:children/state/AppState.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:children/widgets/error_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:children/services/storage_service.dart';
import 'package:children/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<User?> signInWithGoogle() async {
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
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code}');
      // ErrorDialog(errorMessage: 'Error signing in with Google');
    } catch (e) {
      // ErrorDialog(errorMessage: 'Error signing in with Google = ${e.toString()}');
      print('Sign in error: $e');
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (userCredential.user != null) { 
        prefs.setString('email', userCredential.user!.email!);
        prefs.setString('uid', userCredential.user!.uid);
        final appState = AppState();
        appState.setUserId(userCredential.user!.uid);
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code}');
      // ErrorDialog(errorMessage: 'Error signing in with email and password');
      return null;
    }
  }

  Future<AppUser?> signUpWithEmailAndPassword(
      String email, String password, String displayName, File? profileImage) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', userCredential.user!.email!);
          prefs.setString('uid', userCredential.user!.uid);
          String imageUrl = '';
          if (profileImage != null) {
            imageUrl = await StorageService().uploadProfileImage(profileImage, userCredential.user!.uid);
          }
          // 登錄成功後，獲取FCM令牌
          String? token = await _messaging.getToken();
          await FirestoreService().addUser(AppUser(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            displayName: displayName,
            profileImageUrl: imageUrl,
            fcmToken: token!,
          ));
          return AppUser(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            displayName: displayName,
            profileImageUrl: imageUrl,
            fcmToken: token,
          );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // ErrorDialog(errorMessage: 'The password provided is too weak.');
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        // ErrorDialog(errorMessage: 'The account already exists for that email.');
        throw 'The account already exists for that email.';
      } else {
        // ErrorDialog(errorMessage: 'Error signing up with email and password');
        throw 'Error signing up with email and password';
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // sigout googleAccount
  Future<void> signOutGoogle() async {
    await _auth.signOut();
    // await GoogleSignIn().signOut();
  }
}
