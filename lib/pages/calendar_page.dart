import './daily_records_page.dart';
import '../models/baby_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import 'package:children/state/AppState.dart';
import 'package:children/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';




class CalendarPage extends StatefulWidget {
  static const routeName = '/calendar';
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 日曆的控制器與選定日期
  late final ValueNotifier<DateTime> _focusedDate;
  DateTime? _selectedDate;
  // 紀錄資料 (以日期為 key，對應該日所有紀錄)
  // 例如 { 2023-01-01: [recordA, recordB], 2023-01-02: [recordC], ... }
  Map<DateTime, List<BabyRecord>> _groupedRecords = {};
  String userId = '';
  @override
  void initState() {
    super.initState();
    _focusedDate = ValueNotifier(DateTime.now());
    final appState = AppState.of(context);
    userId = appState.uid;

  }

  @override
  void dispose() {
    _focusedDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pushNamed(HomePage.routeName);
          },
        ),
        title: Text(
          '生活日曆',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamed('/');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BabyRecord>>(
        stream: firestoreService.getBabyRecords(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('抓取資料錯誤'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRecords = snapshot.data!;
          // 建立 Map<DateTime, List<BabyRecord>>
          _groupedRecords = _groupRecordsByDate(allRecords);

          return _buildCalendar();
        },
      ),
    );
  }

  // 使用 table_calendar 套件，建立日曆 UI
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(2018, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: _focusedDate.value,
      // 選擇模式是 "多個頁面" 還是 "只顯示單個月" 等
      calendarFormat: CalendarFormat.month,
      // 每次點擊日期時
      onDaySelected: (selectedDate, focusedDate) {
        setState(() {
          _selectedDate = selectedDate;
          _focusedDate.value = focusedDate;
        });
        // 跳到 daily_records_page 顯示該日資料
        final _records = _groupedRecords[_normalizeDate(selectedDate)];
        if (_records != null) {
          final _recordsForSelectedDate =
              _groupedRecords[_normalizeDate(selectedDate)];
          if (_recordsForSelectedDate != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DailyRecordsPage(
                      date: selectedDate, records: _recordsForSelectedDate)),
            );
          }
        }
      },
      // 那天是選定的日期時，顯示該日期
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      // 建立事件標記: 若該日有紀錄 => 顯示一個點或其他樣式
      eventLoader: (day) {
        // 回傳該日有多少筆紀錄，之後table_calendar會在該日顯示事件指示
        final normalizedDate = _normalizeDate(day);

        return _groupedRecords[normalizedDate] ?? [];
      },
      // 可自訂畫面 (有紀錄的日期顯示點點)
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return Positioned(
              right: 1,
              bottom: 1,
              child: _buildEventMarker(events.length),
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  /// 把 DateTime 只留年月日 (HH:mm:ss清為0)，避免時區誤差
  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// 分組所有紀錄，以 [yyyy-MM-dd] 為key (直接使用 DateTime，但只留年月日)
  Map<DateTime, List<BabyRecord>> _groupRecordsByDate(
      List<BabyRecord> allRecords) {
    final Map<DateTime, List<BabyRecord>> dateRecords = {};
    for (var record in allRecords) {
      final dateKey = _normalizeDate(record.date);
      // dateRecords[dateKey] = [...(dateRecords[dateKey] ?? []), record];
      if (dateRecords[dateKey] == null) {
        dateRecords[dateKey] = [record];
      } else {
        dateRecords[dateKey]!.add(record);
      }
    }
    return dateRecords;
  }

  Widget _buildEventMarker(int count) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
