import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/AiChat/ai_assistant_page.dart';

import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/Statistic/calender_Page.dart';
import 'package:flutter/material.dart';


class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedIndex = 0; // Start on the AI Assistant tab by default


void _navigateToPage(int index, BuildContext context) {
    Widget page;

    switch (index) {
      case 1:
        page = const StatisticsPage();
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
      appBar: AppBar(
        title: const Text('Statistics Page'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Hello! This is the Statistics page.',
          style: TextStyle(fontSize: 24),
        ),
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
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Assistant'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],

  
      ),
    );
  }
}