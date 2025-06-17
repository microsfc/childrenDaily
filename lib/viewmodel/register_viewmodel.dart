import 'dart:io';
import '../utils/result.dart';
import '../models/appuser.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;
  
  bool _isLoading = false;
  String? _error;
  File? _profileImage;

  RegisterViewModel(this._authService);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get profileImage => _profileImage;
  
  void setProfileImage(File? image) {
    _profileImage = image;
    notifyListeners();
  }
  
  Future<Result<AppUser>> register(
    String email, 
    String password, 
    String displayName
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
        _profileImage
      );
      
      _isLoading = false;
      
      if (user != null) {
        notifyListeners();
        return Result.success(user);
      } else {
        _error = 'Failed to register';
        notifyListeners();
        return Result.error(_error!);
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return Result.error(_error!);
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}