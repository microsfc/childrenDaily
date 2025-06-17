import 'ui/theme.dart';
import 'di/locator.dart';
import 'config/config.dart';
import 'generated/l10n.dart';
import 'pages/home_page.dart';
import 'state/auth_state.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'state/record_state.dart';
import 'models/baby_record.dart';
import 'pages/calendar_page.dart';
import 'pages/timeline_page.dart';
import 'state/calendar_state.dart';
import 'pages/payment_screen.dart';
import 'services/fcm_service.dart';
import 'pages/add_record_page.dart';
import 'services/storage_service.dart';
import 'package:flutter/material.dart';
import 'pages/record_detail_page.dart';
import 'pages/daily_records_page.dart';
import 'package:provider/provider.dart';
import 'pages/height_weight_chart.dart';
import 'services/navigation_service.dart';
import 'package:children/state/AppState.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:children/services/firestore_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';




// Handle FCM background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Received background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize Stripe
  Stripe.publishableKey = "pk_test_51QrsraCiI9KAAR1QoiaDEXhJQdBc7k1Oe6jxi2HBVpuNtHFJfRoE6RC1BHaLfbTHVYGTVVVrTJCpjl5Lqjp4It9S00PHsTWeL1";
  
  // Set up dependency injection
  await setupLocator();
  
  // Initialize FCM
  await locator<FCMService>().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // You can remove individual providers as they're now handled by GetIt
        // Just keep the ChangeNotifier providers for UI updates
        ChangeNotifierProvider.value(value: locator<AuthState>()),
        ChangeNotifierProvider.value(value: locator<RecordsState>()),
        ChangeNotifierProvider.value(value: locator<CalendarState>()),
        ChangeNotifierProvider.value(value: locator<AppState>()),
        Provider<StorageService>(create: (_) => FirebaseStorageService(FirebaseStorage.instance)),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'Baby Growth Tracker',
        navigatorKey: locator<NavigationService>().navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AppStartPage(),
        routes: {
          LoginPage.routeName: (context) => LoginPage(),
          HomePage.routeName: (context) => HomePage(),
          TimelinePage.routeName: (context) => TimelinePage(),
          AddRecordPage.routeName: (context) => AddRecordPage(),
          CalendarPage.routeName: (context) => CalendarPage(),
          PaymentScreen.routeName: (context) => PaymentScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case RecordDetailPage.routeName:
              final record = settings.arguments as BabyRecord;
              return MaterialPageRoute(
                builder: (context) => RecordDetailPage(record: record),
              );
            case DailyRecordsPage.routeName:
              final date = settings.arguments as DateTime;
              return MaterialPageRoute(
                builder: (context) {
                  return DailyRecordsPage(date: date, records: []);
                },
              );
            case GrowthChartPage.routeName:
              final rangeInYears = settings.arguments as int? ?? 1;
              return MaterialPageRoute(
                builder: (context) => GrowthChartPage(rangeInYears: rangeInYears),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

// Determine initial route based on authentication state
class AppStartPage extends StatelessWidget {
  const AppStartPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    
    return authState.isAuthenticated
        ? const HomePage()
        : LoginPage();
  }
}