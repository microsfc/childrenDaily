import 'pages/home_page.dart';
import 'pages/timeline_page.dart';
import './models/baby_record.dart';
import 'pages/add_record_page.dart';
import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'pages/record_detail_page.dart';
import 'package:provider/provider.dart';
import 'services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // FlutterFire CLI 產生

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
      ],
      child: MaterialApp(
        title: 'Baby Growth Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.light),
        ),
        themeMode: ThemeMode.system,
        home: const HomePage(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case HomePage.routeName:
              return MaterialPageRoute(builder: (context) => const HomePage());
            case TimelinePage.routeName:
              return MaterialPageRoute(
                  builder: (context) => const TimelinePage());
            case AddRecordPage.routeName:
              return MaterialPageRoute(
                  builder: (context) => const AddRecordPage());
            case RecordDetailPage.routeName:
              final record = settings.arguments as BabyRecord;
              return MaterialPageRoute(
                  builder: (context) => RecordDetailPage(record: record));
            default:
              return null;
          }
        },
      ),
    );
  }
}
