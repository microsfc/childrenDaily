import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import 'package:provider/provider.dart';
import '../services/calendar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 導入 Flutter Local Notifications

class CalendarEventPage extends StatefulWidget {
  const CalendarEventPage({super.key});
  static const routeName = '/calendarEvent';

  @override
  _CalendarEventPageState createState() => _CalendarEventPageState();
}

class _CalendarEventPageState extends State<CalendarEventPage> {
  DateTime? _selectedDay;
  late final ValueNotifier<List<CalendarEvent>> _selectedEvents;
  CalendarService? _calendarService;
  List<CalendarEvent> _allEvents = []; // 儲存所有事件 (從 StreamBuilder 接收)
  List<NeatCleanCalendarEvent> _neatEvents = []; // flutter_neat_and_clean_calendar 的事件格式
  bool test = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    // _selectedEvents.value = _getEventsForDay(_selectedDay!);
    //  _requestPermissions();
    //  _configureForegroundAndBackgroundNotifications();
    //  _getTokenAndUpload()
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calendarService = Provider.of<CalendarService>(context);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // 取得特定日期的事件
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _allEvents.where((event) {
      return isSameDay(event.startTime, day);
    }).toList();
  }

  bool isSameDay(DateTime dayA, DateTime dayB) {
    return dayA.year == dayB.year && dayA.month == dayB.month && dayA.day == dayB.day;
  }

  // 顯示新增事件對話框
  Future<CalendarEvent?> _showAddEventDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime startTime = _selectedDay!;
    DateTime endTime = _selectedDay!.add(Duration(hours: 1));
    List<String> selectedUsers = [];

    ValueNotifier<TimeOfDay> inputStartTime = ValueNotifier(TimeOfDay.fromDateTime(startTime));
    ValueNotifier<TimeOfDay> inputEndTime = ValueNotifier(TimeOfDay.fromDateTime(endTime));

    return showDialog<CalendarEvent>(context: context,
     builder: (BuildContext context) {
      return AlertDialog(
        title: Text('新增事件'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '輸入標題',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: '輸入描述',
                ),
              ),  
              Row(
                  children: [
                  const Text('開始時間'),
                  ValueListenableBuilder(
                    valueListenable: inputStartTime, 
                    builder: (context, startTime, _) {
                      return Text(startTime.format(context));
                  }),
                  IconButton(
                   onPressed: () async {
                    final TimeOfDay? pickTime = await showTimePicker(
                      context: context,
                      initialTime: inputStartTime.value,
                    );
                    if (pickTime != null) {
                      setState(() {
                        inputStartTime.value = pickTime;
                      });
                    }
                   },
                   icon: Icon(Icons.access_time),
                  )
                ]
              ),
              Row(
                children: [
                  const Text('結束時間'),
                  ValueListenableBuilder(
                    valueListenable: inputEndTime, 
                    builder: (context, endTime, _) {
                      return Text(endTime.format(context));
                  }),
                  IconButton(
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: inputEndTime.value
                          );
                          if (pickedTime != null) {
                            setState(() {
                              inputEndTime.value = pickedTime;
                            });
                          }
                    },
                    icon: Icon(Icons.access_time),
                  )
                ],),
                SizedBox(height: 20),
                const Text('分享給其他使用者:', style: TextStyle(fontWeight: FontWeight.bold)),
                StreamBuilder(stream:
                              FirebaseFirestore.instance.collection('users').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('抓取資料錯誤');
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                List<Widget> sharedUserList = [];
                                for(var doc in snapshot.data!.docs) {
                                  final userId = doc['uid'];
                                  // Avoid sharing with the event creator
                                  if (userId == Provider.of<CalendarService>(context, listen: false).getCurrentUserId()) {
                                    continue;
                                  }
                                  final userData = doc.data();
                                  final displayName = userData['displayName'] ?? '';
                                  sharedUserList.add(
                                    StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return SwitchListTile(
                                          // key: ValueKey(userId),
                                          title: Text(displayName),
                                          value: selectedUsers.contains(userId),
                                          onChanged: (bool newValue) {
                                            setState(() {
                                              if (newValue) {
                                                // add to sharedWith
                                                selectedUsers.add(userId);                                              
                                              } else {
                                                // remove from sharedWith
                                                selectedUsers.remove(userId);
                                              }
                                            });
                                          },
                                        ); 
                                      }
                                    )
                                  );
                                }
                                return Column(
                                  children: sharedUserList,
                                );
                              }
                            )

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final userId = Provider.of<CalendarService>(context, listen: false).getCurrentUserId();
              if (userId == null) {
                Navigator.of(context).pop(null);
              } else {
                selectedUsers.add(userId);
                  final newEvent = CalendarEvent(
                    id: '',
                    creatorId: userId,
                    title: titleController.text,
                    description: descriptionController.text,
                    startTime: DateTime(
                      _selectedDay!.year, 
                      _selectedDay!.month, 
                      _selectedDay!.day, 
                      inputStartTime.value.hour, 
                      inputStartTime.value.minute
                    ),
                    endTime: DateTime(
                      _selectedDay!.year, 
                      _selectedDay!.month, 
                      _selectedDay!.day, 
                      inputEndTime.value.hour, 
                      inputEndTime.value.minute
                    ),
                    sharedWith: selectedUsers,
                  );
                  Navigator.of(context).pop(newEvent);  
              }
            },
            child: Text('新增'),
          ),
        ],
      );
     }      
    );
  }

// 顯示編輯事件對話框
  Future<CalendarEvent?> _showEditEventDialog(CalendarEvent eventToEdit) async {
    TextEditingController _titleController = TextEditingController(text: eventToEdit.title);
    TextEditingController _descriptionController = TextEditingController(text: eventToEdit.description);
    DateTime _startTime = eventToEdit.startTime;
    DateTime _endTime = eventToEdit.endTime;
    List<String> selectedUsers = [];

    return showDialog<CalendarEvent>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('編輯事件'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '標題'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '描述'),
                ),
                Row(
                  children: <Widget>[
                    const Text('開始時間: '),
                    Text(DateFormat('yyyy-MM-dd HH:mm').format(_startTime)),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_startTime),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, pickedTime.hour, pickedTime.minute);
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Text('結束時間: '),
                    Text(DateFormat('yyyy-MM-dd HH:mm').format(_endTime)),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_endTime),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, pickedTime.hour, pickedTime.minute);
                          });
                        }
                      },
                    ),
                  ],
                ),
                StreamBuilder(stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('抓取資料錯誤');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      List<Widget> sharedUserList = [];
                      for(var doc in snapshot.data!.docs) {
                        final userId = doc['uid'];
                        // Avoid sharing with the event creator
                        if (userId == Provider.of<CalendarService>(context, listen: false).getCurrentUserId()) {
                          continue;
                        }
                        final userData = doc.data();
                        final displayName = userData['displayName'] ?? '';
                        sharedUserList.add(
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return SwitchListTile(
                                // key: ValueKey(userId),
                                title: Text(displayName),
                                value: selectedUsers.contains(userId),
                                onChanged: (bool newValue) {
                                  setState(() {
                                    if (newValue) {
                                      // add to sharedWith
                                      selectedUsers.add(userId);                                              
                                    } else {
                                      // remove from sharedWith
                                      selectedUsers.remove(userId);
                                    }
                                  });
                                },
                              ); 
                            }
                          )
                        );
                      }
                      return Column(
                        children: sharedUserList,
                      );
                    }
                  )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            ElevatedButton(
              child: const Text('儲存'),
              onPressed: () {
                final updatedEvent = CalendarEvent(
                  id: eventToEdit.id,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  startTime: _startTime,
                  endTime: _endTime,
                  creatorId: eventToEdit.creatorId, // 保留創建者 ID
                  sharedWith: eventToEdit.sharedWith, // 保留共享用戶列表
                );
                Navigator.of(context).pop(updatedEvent);
              },
            ),
          ],
        );
      },
    );
  }

  // 顯示確認刪除對話框
  Future<bool> _showConfirmDeleteDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除事件？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false); // 返回 false，不刪除
              },
            ),
            ElevatedButton(
              child: const Text('刪除'),
              onPressed: () {
                Navigator.of(context).pop(true);  // 返回 true，確認刪除
              },
            ),
          ],
        );
      },
    ) ?? false; // 如果 showDialog 返回 null，預設為 false (不刪除)
  }

  void _selectDay(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
    });
  }
  
  // // 選擇日期 (flutter_neat_and_clean_calendar 使用 onDateChange 回調)
  void _onDateChange(DateTime date) {
    // setState(() {
    //   _selectedEvents.value = _getEventsForDay(date);
    // });
    _selectedDay = date;
    _buildEventList(date);
  }

  // 新增事件
  void addEvent() async {
    if (_calendarService == null) {
      return;
    }
    final event = await _showAddEventDialog();
    if (event != null) {
      final CalendarEvent? newEvent = await _calendarService!.createEvent(event);
      if (newEvent != null) {
        _buildEventList(_selectedDay);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('新增事件成功')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('新增事件失敗')));
      }
    }
  }

  // 編輯事件
  void editEvent(CalendarEvent event) async {
    final updatedEvent = await _showEditEventDialog(event);
    if (updatedEvent != null) {
      final CalendarEvent? updateEvent = await _calendarService!.updateEvent(updatedEvent);
      if (updateEvent != null) {
        _buildEventList(_selectedDay);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('編輯事件成功')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('編輯事件失敗')));
      }
    }
  }
  
  // 刪除事件
  void deleteEvent(CalendarEvent event) async {
    final confirmDelete = await _showConfirmDeleteDialog();
    if (confirmDelete) {
      final bool success = await _calendarService!.deleteEvent(event.id);
      if (success) {
        _buildEventList(_selectedDay);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('刪除事件成功')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('刪除事件失敗')));
      }
    }
  }

  // 顯示事件列表
  Widget _buildEventList(DateTime? selectedDay) {
    if (selectedDay == null) {
       _selectedEvents.value = _getEventsForDay(DateTime.now());
    } else {
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
    
    return ValueListenableBuilder(
      valueListenable: _selectedEvents, 
      builder: (context, events, _) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return ListTile(
              title: Text(event.title),
              subtitle: Text('${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)} - ${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editEvent(event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteEvent(event),
                  ),
                ],
              )
              // onTap: () => editEvent(event),
              // onLongPress: () => deleteEvent(event),
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('共享行事曆'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: addEvent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          StreamBuilder<List<CalendarEvent>>(
            stream: _calendarService!.getAllEventsWithSharedUser(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child:  Text('抓取資料錯誤'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('沒有資料'));
              }              
              _allEvents = snapshot.data as List<CalendarEvent>;
              _neatEvents = _buildNeatCleanCalendarEventsMap(_allEvents);
              
              return Calendar(
                initialDate: DateTime.now(),
                startOnMonday: true,
                weekDays: ['Mo', 'Tu', 'Wen', 'Thu', 'Fri', 'Sat', 'Sun'],
                eventsList: _neatEvents,
                eventDoneColor: Colors.green,
                selectedColor: Colors.pink,
                selectedTodayColor: Colors.red,
                todayColor: Colors.blue,
                eventColor: null,
                locale: 'zh',
                expandableDateFormat: 'EEE dd MMM yyyy',
                dayOfWeekStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,),
                defaultDayColor: Colors.black87,

                hideTodayIcon: true,
                hideArrows: false,
                onDateSelected: (date) => _onDateChange(date),
                isExpanded: true,
                eventListBuilder: _buildNeatCleanCalendarEventList,
                // onRangeSelected: (range) {
                //   print('Range selected: $range');
                // },
              );

            }
          ),
          SizedBox(height: 8),
          Expanded(
            child: _buildEventList(null),
          ),
        ],
      ),
    );
  }

  // 將 CalendarEvent 列表轉換為 List<NeatCleanCalendarEvent>格式 (flutter_neat_and_clean_calendar 需要的格式)
  List<NeatCleanCalendarEvent> _buildNeatCleanCalendarEventsMap(List<CalendarEvent> events) {
    List<NeatCleanCalendarEvent> eventMap = [];
    for (var event in events) {
      // DateTime dateKey = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      // if (!eventMap.containsKey(dateKey)) {
      //   eventMap[dateKey] = [];
      // }
      // 轉換為 NeatCleanCalendarEvent
      eventMap.add(NeatCleanCalendarEvent(
        event.title,
        startTime: event.startTime,
        endTime: event.endTime,
        description: event.description,
        color: Colors.blue, // 可以自訂顏色
        isMultiDay: event.startTime.day != event.endTime.day, // 判斷是否為多日事件
      ));
    }
    return eventMap;
  }
  
  // 自訂 flutter_neat_and_clean_calendar 的事件列表樣式
  Widget _buildNeatCleanCalendarEventList(BuildContext context, List<NeatCleanCalendarEvent> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          leading: Icon(Icons.event),
          title: Text(event.summary), // 使用 summary (即 NeatCleanCalendarEvent 的事件標題)
          subtitle: Text('${DateFormat('HH:mm').format(event.startTime!)} - ${DateFormat('HH:mm').format(event.endTime!)}'),
          // 可以根據需要添加更多事件資訊
        );
      },
    );
  }

  
}

