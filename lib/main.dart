import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/timeline_page.dart';
import 'pages/calendar_page.dart';
import './models/baby_record.dart';
import 'pages/add_record_page.dart';
import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'pages/record_detail_page.dart';
import 'pages/daily_records_page.dart';
import 'package:provider/provider.dart';
import 'services/firestore_service.dart';
import 'package:children/state/AppState.dart';
import 'package:children/generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:children/pages/payment_screen.dart';
import 'package:children/services/auth_service.dart';
import 'firebase_options.dart'; // FlutterFire CLI 產生
import 'package:children/pages/height_weight_chart.dart';
import 'package:children/services/calendar_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 導入 Firebase Messaging
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 導入 Flutter Local Notifications



final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
// 定義通知處理背景服務
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('收到背景通知: ${message.notification?.title}');
  // 不需要在這裡顯示通知，系統會自動處理
}

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// 📌 設定 Stripe API Key
  Stripe.publishableKey = "pk_test_51QrsraCiI9KAAR1QoiaDEXhJQdBc7k1Oe6jxi2HBVpuNtHFJfRoE6RC1BHaLfbTHVYGTVVVrTJCpjl5Lqjp4It9S00PHsTWeL1"; // <--- 你的 Publishable Key

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 設置背景消息處理器
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // 創建 Android 通知頻道
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 設置 iOS 通知設定
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<CalendarService>(create: (_) => CalendarService()),
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.light),
        ),
        themeMode: ThemeMode.system,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: LoginPage(),
        navigatorObservers: [routeObserver],
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case LoginPage.routeName:
              return MaterialPageRoute(builder: (context) => LoginPage());
            case HomePage.routeName:
              return MaterialPageRoute(builder: (context) => const HomePage());
            case TimelinePage.routeName:
              return MaterialPageRoute(builder: (context) => TimelinePage());
            case AddRecordPage.routeName:
            final record = settings.arguments as BabyRecord?;
            return MaterialPageRoute(
              builder: (_) => AddRecordPage(record: record),
            );
            case RecordDetailPage.routeName:
              final record = settings.arguments as BabyRecord;
              return MaterialPageRoute(
                  builder: (context) => RecordDetailPage(record: record));
            case CalendarPage.routeName:
              return MaterialPageRoute(
                  builder: (context) => const CalendarPage());
            case DailyRecordsPage.routeName:
              final date = settings.arguments as DateTime;
              final records = settings.arguments as List<BabyRecord>;
              return MaterialPageRoute(
                  builder: (context) =>
                      DailyRecordsPage(date: date, records: records));
            case GrowthChartPage.routeName:
              final rangeInYears = settings.arguments as int;
              return MaterialPageRoute(
                  builder: (context) =>
                      GrowthChartPage(rangeInYears: rangeInYears));
            case PaymentScreen.routeName:
              return MaterialPageRoute(builder: (context) => PaymentScreen());
            case '/':
              return MaterialPageRoute(builder: (context) => LoginPage());

            default:
              return null;
          }
        },
      ),
    );
  }
}
