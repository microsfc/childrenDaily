import './timeline_page.dart';
import './calendar_page.dart';
import './add_record_page.dart';
import '../generated/l10n.dart';
import './calendarEvent_page.dart';
import './height_weight_chart.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
