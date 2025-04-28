import 'dart:convert';
import './timeline_page.dart';
import './calendar_page.dart';
import './add_record_page.dart';
import '../generated/l10n.dart';
import './calendarEvent_page.dart';
import './height_weight_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:children/state/AppState.dart';
import 'package:children/models/appuser.dart';
import 'package:children/bloc/record_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:children/bloc/record_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:children/services/firestore_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';




// 創建通知頻道 ID 和名稱
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'event_reminders_channel', // id
  '事件提醒', // title
  description: '接收即將開始的事件提醒', // description
  importance: Importance.high,
);

// 初始化 FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _screenList = [
    TimelinePage(),
    const AddRecordPage(),
    const CalendarPage(),
    const GrowthChartPage(rangeInYears: 1),
    const CalendarEventPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化通知處理
    setupInteractedMessage();
    // 請求權限並獲取Token
    requestPermissionAndGetToken();
    
    // 監聽 token 刷新事件
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      print('FCM Token 已刷新: $token');
      // 更新 Firestore 中的 token
      final appState = AppState.of(context);
        AppUser? updateUser = appState.currentUser;
        updateUser!.fcmToken = token;

        await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: updateUser.uid)
            .get()
            .then((QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            // 更新 Firestore 中的用戶資料
            FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.docs[0].id)
                .update(updateUser.toMap());
          }});
    });
    
    // 設置本地通知點擊事件
    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('點擊本地通知: ${response.payload}');
        if (response.payload != null) {
          Map<String, dynamic> data = jsonDecode(response.payload!);
          if (data['eventId'] != null) {
            // 導航到事件詳情頁面
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CalendarEventPage(),
              ),
            );
          }
        }
      },
    );
  }

  // 處理通知點擊事件
  void _handleMessage(RemoteMessage message) {
    print('處理通知點擊: ${message.data}');
    if (message.data['eventId'] != null) {
      // 導航到事件詳情頁面
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CalendarEventPage(),
        ),
      );
    }
  }

  // 請求通知權限並獲取 FCM Token
  Future<void> requestPermissionAndGetToken() async {
    // 請求通知權限
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('使用者通知授權狀態: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 獲取 FCM Token
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && token != null) {
        final appState = AppState.of(context);
        AppUser? updateUser = appState.currentUser;
        updateUser!.fcmToken = token;

        await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: currentUser.uid)
            .get()
            .then((QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            // 更新 Firestore 中的用戶資料
            FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.docs[0].id)
                .update(updateUser.toMap());
          }});
      }
    }
  }

  // 初始化處理通知相關設定
  Future<void> setupInteractedMessage() async {
    // 獲取從終止狀態打開應用程式的通知
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    // 如果應用程式是通過點擊通知打開的，處理通知內容
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // 設置前景通知處理器
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('收到前景通知: ${message.notification?.title}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // 如果通知不為空且在 Android 平台上
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 設置通知點擊處理器（當應用在背景但未終止時）
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    return BlocProvider(
      create: (_) => RecordBloc(firestoreService: FirestoreService())..add(LoadRecordEvent(appState.currentUser!.uid, false, '')),
      child: Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (child, animation, secondaryAnimation) =>
            //     FadeThroughTransition(
            //   animation: animation,
            //   secondaryAnimation: secondaryAnimation,
            //   child: child,
            // ),
          SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          // Choose one of the three types: horizontal, vertical, or scaled
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        child: _screenList[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: "Timeline",
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_a_photo),
            label: "Addd Record",
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month),
            label: "Calendar",
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart),
            label: "Growth Chart",
          ),
          NavigationDestination(
            icon: const Icon(Icons.event),
            label: "Calendar Event",
          ),
        ],
        onDestinationSelected: _onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    ));
  }
}
