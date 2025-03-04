import 'package:final_project/HomePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/ai_assistant_page.dart';
import 'package:final_project/HomePage1/calendar_page.dart';
import 'package:final_project/HomePage1/statistics_page.dart';
import 'package:flutter/material.dart';


class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  // Start on index 4 so that "Personal" is highlighted initially.
  int _selectedIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Page'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Hello! This is the Personal page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // All five buttons show labels
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate based on the tapped index:
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePageFirst()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const StatisticsPage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AiAssistantPage()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            );
          }
          // index == 4 => already here, so do nothing
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'statistics',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'finalProject_img/ai.png',
              width: 50,
              height: 50,
            ),
            label: 'AI assistant',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}