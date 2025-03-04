import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Track currently focused day and selected day
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Example events map, or fetch from DB
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2023, 3, 14): ['Meeting', 'Study'],
    DateTime.utc(2023, 3, 15): ['Doctor appointment'],
  };

  List<String> _getTasksForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Calendar'),
      ),
      body: Column(
        children: [
          // The TableCalendar widget
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2022),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getTasksForDay,
          ),

          // Display tasks for the currently selected day
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: _getTasksForDay(_selectedDay ?? _focusedDay)
                  .map((task) => ListTile(
                        title: Text(task),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}