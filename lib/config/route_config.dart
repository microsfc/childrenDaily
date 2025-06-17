import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../models/baby_record.dart';
import '../pages/calendar_page.dart';
import '../pages/timeline_page.dart';
import '../pages/payment_screen.dart';
import 'package:flutter/material.dart';
import '../pages/add_record_page.dart';
import '../pages/daily_records_page.dart';
import '../pages/record_detail_page.dart';
import '../pages/calendarEvent_page.dart';
import '../pages/height_weight_chart.dart';


class RouteConfig {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginPage.routeName:
        return MaterialPageRoute(builder: (context) => LoginPage());
        
      case HomePage.routeName:
        return MaterialPageRoute(builder: (context) => HomePage());
        
      case TimelinePage.routeName:
        return MaterialPageRoute(builder: (context) => TimelinePage());
        
      case AddRecordPage.routeName:
        final record = settings.arguments as BabyRecord?;
        return MaterialPageRoute(
          builder: (context) => AddRecordPage(record: record),
        );
        
      case RecordDetailPage.routeName:
        final record = settings.arguments as BabyRecord;
        return MaterialPageRoute(
          builder: (context) => RecordDetailPage(record: record),
        );
        
      case CalendarPage.routeName:
        return MaterialPageRoute(builder: (context) => const CalendarPage());
        
      case CalendarEventPage.routeName:
        return MaterialPageRoute(builder: (context) => const CalendarEventPage());
        
      case DailyRecordsPage.routeName:
        final date = settings.arguments as DateTime;
        return MaterialPageRoute(
          builder: (context) => DailyRecordsPage(date: date, records: []),
        );
        
      case GrowthChartPage.routeName:
        final rangeInYears = settings.arguments as int? ?? 1;
        return MaterialPageRoute(
          builder: (context) => GrowthChartPage(rangeInYears: rangeInYears),
        );
        
      case PaymentScreen.routeName:
        return MaterialPageRoute(builder: (context) => PaymentScreen());
        
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  // Named route transition animation
  static PageRouteBuilder<dynamic> buildPageRoute({
    required RouteSettings settings,
    required Widget page,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}