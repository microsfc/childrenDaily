import '../models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/calendar_provider.dart';

class EditEventDialog extends StatefulWidget {
  final Event? event;

  const EditEventDialog({super.key, required this.event});

  @override
  _EditEventDialogState createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.event?.title ?? '';
    _descriptionController.text = widget.event?.description ?? '';
    _selectedDate = widget.event?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('編輯事件'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: '事件名稱'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: '事件描述'),
          ),
          Row (
            children: [
              Text('日期：'),
              Text('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
              Spacer(),
              ElevatedButton(onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2015, 8),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              }, child: Text('選擇日期')),
          ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            final event = Event(
              id: widget.event?.id,
              title: _titleController.text,
              description: _descriptionController.text,
              date: _selectedDate,
            );
            if (event.id != null) {
              Provider.of<CalendarProvider>(context, listen: false).updateEvent(event);
            } else {
              Provider.of<CalendarProvider>(context, listen: false).addEvent(event);
            }
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
