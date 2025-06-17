import 'dart:io';
import '../utils/result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children/models/appuser.dart';
import '../repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:children/services/auth_service.dart';




class AuthState with ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;
  AuthState(this._authService, this._userRepository) {
    // Initialize the auth state
     _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _uid = user.uid;
        notifyListeners();
      }
    });
  }

  String _uid = '';
  String _profileImageDownloadUrl = '';
  String _fcmToken = '';
  AppUser? _currentUser;
  String? _error;
  bool _isLoading = false;

  String get uid => _uid;
  AppUser? get currentUser => _currentUser;
  String get profileImageDownloadUrl => _profileImageDownloadUrl;
  String get fcmToken => _fcmToken;
  String get error => _error ?? '';
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

   
  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void setProfileImageDownloadUrl(String url) {
    _profileImageDownloadUrl = url;
    notifyListeners();
  }

  void setFcmToken(String token) {
    _fcmToken = token;
    notifyListeners();
  }

  // Sign in with email and password
  Future<Result<AppUser?>> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      final AppUser? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return Result.success(user);
      } else {
        return Result.error('Invalid email or password');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners(); 
      return Result.error(e.toString());
    }
  }

  // Sign up with email and password
  Future<Result<AppUser?>> signUpWithEmailAndPassword(String email, String password, String displayName, File? profileImageUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {  
      final AppUser? user = await _authService.signUpWithEmailAndPassword(email, password, displayName, profileImageUrl);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return Result.success(user);
      } else {
        return Result.error('Sign up failed');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners(); 
      return Result.error(e.toString());
    }
  }

  // Sign in with Google
  Future<Result<AppUser?>> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final AppUser? user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return Result.success(user);
      } else {
        return Result.error('Google sign in failed');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners(); 
      return Result.error(e.toString());
    }
  }
  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _uid = '';
    _currentUser = null;
    _profileImageDownloadUrl = '';
    _fcmToken = '';
    _isLoading = false;
    notifyListeners();
  }
  // update FCM token
  Future<void> updateFcmToken(String token) async {
    _fcmToken = token;
    notifyListeners();
    if (_currentUser != null) {
      _currentUser!.fcmToken = token;
      await _userRepository.updateUser(_currentUser!);
    }
  }

  static AuthState of(BuildContext context) {
    return Provider.of<AuthState>(context, listen: false);
  }
}
