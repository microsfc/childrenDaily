import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class FCMService {
  Future<void> initialize();
  Future<String?> getToken();
  Future<void> requestPermission();
  void setupForegroundNotificationHandler();
  Future<void> setupBackgroundMessageHandler();
  void handleNotificationClick(Function(RemoteMessage) onNotificationClick);
}

class FCMServiceImpl implements FCMService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  
  // Define notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'event_reminders_channel',
    'Event Reminders',
    description: 'Receive notifications for upcoming events',
    importance: Importance.high,
  );
  
  FCMServiceImpl(this._firebaseMessaging, this._flutterLocalNotificationsPlugin);
  
  @override
  Future<void> initialize() async {
    // Request permission
    await requestPermission();
    
    // Set up handlers
    setupForegroundNotificationHandler();
    await setupBackgroundMessageHandler();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Check for initial message (app opened from terminated state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }
  
  @override
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
  
  @override
  Future<void> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    debugPrint('User notification permission status: ${settings.authorizationStatus}');
  }
  
  Future<void> _initializeLocalNotifications() async {
    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
        
    // Initialize settings
    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          final data = json.decode(response.payload!);
          // Handle the notification data
          debugPrint('Notification payload: $data');
        }
      },
    );
    
    // Configure iOS foreground presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  
  @override
  void setupForegroundNotificationHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');
      
      // Show local notification
      _showLocalNotification(message);
    });
  }
  
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: json.encode(message.data),
      );
    }
  }
  
  @override
  Future<void> setupBackgroundMessageHandler() async {
    // The background handler needs to be registered at the top level
    // It's typically done in main.dart
    debugPrint('Background message handler set up');
  }
  
  @override
  void handleNotificationClick(Function(RemoteMessage) onNotificationClick) {
    // Handle when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked (background): ${message.notification?.title}');
      onNotificationClick(message);
    });
  }
  
  void _handleMessage(RemoteMessage message) {
    // Handle the message as needed
    debugPrint('Handling message: ${message.notification?.title}');
  }
}