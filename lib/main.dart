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
import 'package:firebase_core/firebase_core.dart';
import 'package:children/services/auth_service.dart';
import 'firebase_options.dart'; // FlutterFire CLI 產生
import 'package:children/pages/height_weight_chart.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
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
