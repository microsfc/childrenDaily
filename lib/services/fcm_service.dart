import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationPermissionStatus {
  granted,
  denied,
  provisional,
  unknown,
}

abstract class FCMService {
  Future<void> initialize();
  Future<String?> getToken();
  Future<NotificationPermissionStatus> requestPermission();
  void setupForegroundNotificationHandler();
  Future<void> setupBackgroundMessageHandler();
  void handleNotificationClick(Function(RemoteMessage) onNotificationClick);
  Future <void> subscribeToTopic(String topic);
  Future <void> unsubscribeFromTopic(String topic);
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
    final permissionStatus = await requestPermission();

    if (permissionStatus != NotificationPermissionStatus.granted) {
      debugPrint('Notification permission not granted: $permissionStatus');
      return;
    }
    
    // Set up handlers
    setupForegroundNotificationHandler();
    await setupBackgroundMessageHandler();
    // Initialize local notifications
    await _initializeLocalNotifications();
    // handleNotificationClick(_handleMessage);
    
    // Check for initial message (app opened from terminated state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }
  
  @override
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM token: $token');
        return token;
      } else {
        debugPrint('Failed to get FCM token');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
    
  }
  
  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    try {
        final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          debugPrint('User granted notification permission');
          return NotificationPermissionStatus.granted;
        case AuthorizationStatus.denied:
          debugPrint('User denied notification permission');
          return NotificationPermissionStatus.denied;
        case AuthorizationStatus.provisional:
          debugPrint('User granted provisional notification permission');
          return NotificationPermissionStatus.provisional;
        default:
          debugPrint('User notification permission status: ${settings.authorizationStatus}');
          return NotificationPermissionStatus.unknown;
      }
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return NotificationPermissionStatus.unknown;
    }
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
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          final data = json.decode(response.payload!);
          // Handle the notification data, maybe navigate to a specific page
          debugPrint('Notification payload: $data');
          // You can call a function to handle the notification click
          // For example, if you have a function to handle it:
          debugPrint('Notification tapped with payload: $data');
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
    
    if (notification != null) {
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
    // Navigator.pushNamed(
    //   navigatorKey.currentContext!,
    //   '/notification',
    //   arguments: message.data,
    // );
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }
}