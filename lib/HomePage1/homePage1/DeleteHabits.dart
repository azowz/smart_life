import 'package:final_project/HomePage1/AiChat/ai_assistant_page.dart';

import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllHabits.dart';

import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/Statistic/calender_Page.dart';
import 'package:final_project/Statistic/statistics_page.dart';
import 'package:flutter/material.dart';

class DeleteHabits extends StatefulWidget {
  const DeleteHabits({super.key});

  @override
  _DeleteHabitsState createState() => _DeleteHabitsState();
}

class _DeleteHabitsState extends State<DeleteHabits> {
  int _selectedIndex = 0;

  // Navigate to other pages when a tab is selected
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
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3953),
      body: Center(
        child: Container(
          width: 340,
          height: 400,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'finalProject_img/delete.png',
                  width: 139,
                  height: 145,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure want to delete?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmDelete(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F3E0),
                    minimumSize: const Size(258, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewAllHabits(),
                      ),
                    );
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _navigateToPage(index, context); // Navigate when tapping on a tab
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






class ConfirmDelete extends StatefulWidget {
  const ConfirmDelete({super.key});

  @override
  _ConfirmDeleteState createState() => _ConfirmDeleteState();
}

class _ConfirmDeleteState extends State<ConfirmDelete> {
  int _selectedIndex = 0;

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
      backgroundColor: const Color(0xFF2D3953),
      body: Center(
        child: Container(
          width: 340,
          height: 400,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Stack to place the true sign at the top-right of the image
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.asset(
                      'finalProject_img/delete.png', // Using the image instead of icon
                      width: 100, // Adjust the width as needed
                      height: 100, // Adjust the height as needed
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.check_circle,
                        size: 30,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'List has been deleted',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to ViewAllHabits after deletion
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewAllHabits(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F3E0),
                    minimumSize: const Size(258, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _navigateToPage(index, context); // Navigate when tapping on a tab
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