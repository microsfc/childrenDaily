import 'dart:math';
import '../utils/result.dart';
import '../models/appuser.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class LoginViewModel with ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _error;

  LoginViewModel(this._authService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Result<AppUser>> login(String email, String password) async {
    _isLoading = true;
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password); 
        if (user is AppUser) {
          if (user.errorMessage.isNotEmpty) {
            _error = user.errorMessage;
            return Result.error(_error!);
          } else {
            AppUser currentUser = AppUser(
              uid: user.uid,
              fcmToken: '',
              email: user.email,
              displayName: user.displayName,
              profileImageUrl: user.profileImageUrl,
            );
            notifyListeners();
            return Result.success(currentUser);
        }
       } else {
        _error = 'Login failed. Please check your credentials and try again.';
        notifyListeners();
        return Result.error(_error!);
       }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return Result.error(_error!);
    } finally {
      _isLoading = false;
    }
  }

  Future<Result<AppUser>> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      
      if (user == null) {
        _error = 'Google login failed. Please try again.';
        return Result.error(_error!);
      } else {
        AppUser currentUser = AppUser(
          uid: user.uid,
          fcmToken: '',
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          profileImageUrl: user.profileImageUrl ?? '',
        );
        notifyListeners();
        return Result.success(currentUser);
      }
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return Result.error(_error!);
    } finally {
      _isLoading = false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}