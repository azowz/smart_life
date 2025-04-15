import 'package:final_project/HomePage1/AiChat/ai_assistant_page.dart';
import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:flutter/material.dart';
import 'event_card.dart';
import 'reminder_card.dart';
import 'schedule_P.dart'; 
import 'calendar_P.dart';
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }
  int _selectedIndex = 0; // Start on the AI Assistant tab by default


void _navigateToPage(int index, BuildContext context) {
    Widget page;

    switch (index) {
      case 1:
        page = const CalendarPage();
        break;
      case 2:
        page = const AiAssistantPage();
        break;
      case 3:
        page = const CalendarPage();
        break;
      case 4:
        page = const PersonalPage();
        break;
      default:
        page = const HomePageFirst();
        break;
    }
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 200), // Speed up the transition
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child); // Smooth fade transition
      },
    ));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3953),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Calendar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.remove_red_eye, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => calendar_P()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SchedulePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Schedule Today'),
                  EventCard(
                    time: '16.00 - 19.00',
                    title: '3-hour study',
                    subtitle: 'every friday',
                  ),
                  EventCard(
                    time: '22.00 - 23.30',
                    title: 'play football',
                    subtitle: 'every friday',
                  ),
                  _sectionTitle('Reminder'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      "Don't forget schedule for tomorrow",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  ReminderCard(
                    title: 'Read Books',
                    time: '15.00 - 16.00',
                  ),
                  ReminderCard(
                    title: 'Take medication',
                    time: '18.00',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
       // Fix here: Corrected the semicolon after the body section
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
           // Handle navigation and smooth transition
          _navigateToPage(index, context);

          
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Statistics'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'JARVIS'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],

  
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Week Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Wed', 'Th', 'Fr', 'Sa', 'Su', 'Mo', 'Tu']
                .map((day) => Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 10),
          // Dates - First Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [13, 14, 15, 16, 17, 18, 19]
                .map((date) => _buildDateCell(date))
                .toList(),
          ),
          SizedBox(height: 10),
          // Dates - Second Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [20, 21, 22, 23, 24, 25, 26]
                .map((date) => _buildDateCell(date))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCell(int date) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, date);
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _selectedDay != null && _selectedDay!.day == date
              ? Colors.blue
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$date',
            style: TextStyle(
              color: _selectedDay != null && _selectedDay!.day == date
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
