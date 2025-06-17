import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Create a reusable error handling class

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? 'An error occurred';
    
    if (error is FirebaseAuthException) {
      message = _getAuthErrorMessage(error);
    } else if (error is FirebaseException) {
      message = error.message ?? 'Firebase error occurred';
    } else if (error is String) {
      message = error;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  static String _getAuthErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      // Handle other cases
      default:
        return exception.message ?? 'Authentication error';
    }
  }
  
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}