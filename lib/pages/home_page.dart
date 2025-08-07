import 'dart:convert';
import 'timeline_page.dart';
import './calendar_page.dart';
import './add_record_page.dart';
import './calendarEvent_page.dart';
import './height_weight_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children/di/locator.dart';
import 'package:animations/animations.dart';
import 'package:children/state/AppState.dart';
import 'package:children/models/appuser.dart';
import 'package:children/state/auth_state.dart';
import 'package:children/bloc/record_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:children/bloc/record_event.dart';
import 'package:children/models/baby_record.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:children/pages/RecordDetailScreen.dart';
import 'package:children/services/firestore_service.dart';
import 'package:children/services/navigation_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  // List of screens to navigate to
  final _screenList = [
    TimelinePage(),
    RecordDetailScreen(record: BabyRecord.empty('')),
    const CalendarPage(),
    const GrowthChartPage(rangeInYears: 1),
    const CalendarEventPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 設置通知點擊處理器（當應用在背景但未終止時）
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // // 監聽 token 刷新事件
    final appState = AppState.of(context); // Move outside async gap
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      print('FCM Token 已刷新: $token');
      // 更新 Firestore 中的 token
      if (!mounted) return; // Guard with mounted check if needed
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
        }
      });
    });
  }

  // 處理通知點擊事件
  void _handleMessage(RemoteMessage message) {
    print('處理通知點擊: ${message.data}');
    if (message.data['eventId'] != null) {
      // 使用全局的 navigatorKey 來進行導航
      // currentState 可能為 null，所以使用 ?. (null-safe) 運算符更安全
      locator<NavigationService>().navigatorKey.currentState?.push(
        MaterialPageRoute(
          // builder 裡的 context 是由 MaterialPageRoute 新提供的，是安全的
          builder: (context) => CalendarEventPage(),
        ),
      );
    }
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
