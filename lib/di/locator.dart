import 'package:get_it/get_it.dart';
import '../services/calendar_service.dart';
import 'package:children/state/AppState.dart';
import 'package:children/state/auth_state.dart';
import 'package:children/state/record_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:children/state/calendar_state.dart';
import 'package:children/services/fcm_service.dart';
import 'package:children/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:children/services/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:children/viewmodel/login_viewmodel.dart';
import 'package:children/services/firestore_service.dart';
import 'package:children/services/navigation_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:children/repositories/user_repository.dart';
import 'package:children/viewmodel/timeline_viewmodel.dart';
import 'package:children/viewmodel/add_record_viewmodel.dart';
import 'package:children/repositories/calendar_repository.dart';
import 'package:children/repositories/baby_record_repository.dart';
import 'package:children/repositories/measurement_repository.dart';
import 'package:children/repositories/measurement_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final locator = GetIt.instance;
Future<void> setupLocator() async {
  // Firebase Services
  locator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  // 2️⃣ 註冊依賴 —— 先把基礎實體放進去
  locator.registerLazySingleton<FirebaseMessaging>(
        () => FirebaseMessaging.instance);

  locator.registerLazySingleton<FlutterLocalNotificationsPlugin>(
        () => FlutterLocalNotificationsPlugin());

  // Repositories
  locator.registerLazySingleton<BabyRecordRepository>(() => FirestoreBabyRecordRepository(locator<FirebaseFirestore>()));
  locator.registerLazySingleton<UserRepository>(() => FirestoreUserRepository(locator<FirebaseFirestore>()));
  locator.registerLazySingleton<CalendarRepository>(() => FirestoreCalendarRepository(locator<FirebaseFirestore>()));
  locator.registerLazySingleton<MeasurementRepository>(() => FirestoreMeasurementRepository(locator<FirebaseFirestore>()));
  
  // 可以在這裡註冊其他服務
  locator.registerLazySingleton<NavigationService>(() => NavigationService());
  locator.registerLazySingleton<AuthService>(() => FirebaseAuthService(locator<UserRepository>()));
  locator.registerLazySingleton<CalendarService>(() => CalendarServiceImpl(locator<CalendarRepository>()));
  locator.registerLazySingleton<StorageService>(() => FirebaseStorageService(locator<FirebaseStorage>()));
  locator.registerLazySingleton<FCMService>(
    () => FCMServiceImpl(
      locator<FirebaseMessaging>(),
      locator<FlutterLocalNotificationsPlugin>()
    )
  );
  locator.registerLazySingleton<FirestoreService>(() => FirestoreService(
  ));

  // State and Providers
  locator.registerLazySingleton<RecordsState>(() => RecordsState(locator<BabyRecordRepository>()));
  locator.registerLazySingleton<AuthState>(() => AuthState(locator<AuthService>(), locator<UserRepository>()));
  locator.registerLazySingleton<CalendarState>(() => CalendarState(locator<CalendarService>()));
  locator.registerLazySingleton<AppState>(() => AppState()
  );

  locator.registerFactory<LoginViewModel>(() => LoginViewModel(
      locator<AuthService>()
    )
  );
  locator.registerFactory<TimelineViewModel>(() => TimelineViewModel(
      locator<BabyRecordRepository>(),
    )
  );
  locator.registerFactory<AddRecordViewModel>(() => AddRecordViewModel(
      locator<BabyRecordRepository>(),
      locator<MeasurementRepository>(),
      locator<StorageService>(),
    )
  );
}