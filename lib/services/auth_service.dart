import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:children/widgets/error_dialog.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code}');
      // ErrorDialog(errorMessage: 'Error signing in with email and password');
      return null;
    }
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ErrorDialog(errorMessage: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ErrorDialog(errorMessage: 'The account already exists for that email.');
      } else {
        ErrorDialog(errorMessage: 'Error signing up with email and password');
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
