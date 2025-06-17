import 'package:flutter/foundation.dart';

class ApiConfig {
  // Base URLs
  static String get baseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4242';  // Android emulator localhost
    } else {
      return 'http://localhost:4242';  // iOS simulator and web
    }
  }
  
  // Stripe API config
  static const String stripePublishableKey = 
      "pk_test_51QrsraCiI9KAAR1QoiaDEXhJQdBc7k1Oe6jxi2HBVpuNtHFJfRoE6RC1BHaLfbTHVYGTVVVrTJCpjl5Lqjp4It9S00PHsTWeL1";
  
  // Payment API endpoints
  static String get createPaymentIntentUrl => '$baseUrl/create-payment-intent';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API versions
  static const String apiVersion = 'v1';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'x-api-version': apiVersion,
  };
}