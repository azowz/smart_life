import 'package:final_project/HomePage1/AiChat/ai_assistant_page.dart';

import 'package:final_project/HomePage1/homePage1/AddTask.dart';
import 'package:final_project/HomePage1/homePage1/CustomTask.dart';
import 'package:final_project/HomePage1/homePage1/DeleteTask.dart';
import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/HomePage1/Calnder/calender_Page.dart';
import 'package:final_project/statistics_page.dart';
import 'package:flutter/material.dart';

class ViewAllTask extends StatefulWidget {
  const ViewAllTask({super.key});

  @override
  _ViewAllTaskState createState() => _ViewAllTaskState();
}

class _ViewAllTaskState extends State<ViewAllTask> {
  int _selectedIndex = 0;
  bool isChecked1 = false; // Default is false
  bool isChecked2 = false; // Default is false

  void _showMenu(BuildContext context, Offset offset) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: const Text('Edit'),
          onTap: () {
            Future.delayed(Duration.zero, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomTask()),
              );
            });
          },
        ),
        PopupMenuItem(
          child: const Text('Delete'),
          onTap: () {
            Future.delayed(Duration.zero, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeleteTask()),
              );
            });
          },
        ),
      ],
      elevation: 8.0,
    );
  }

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
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D9D9),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePageFirst()),
              );
            },
          ),
        ),
        centerTitle: true,
        title: const Text(
          "All Tasks",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Center(
                child: Text(
                  "+",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTask()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // First Habit Container
          Center(
            child: Container(
              width: 370,
              height: 72,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.5, // Adjust size to 30x30 by scaling
                        child: Checkbox(
                          value: isChecked1,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isChecked1 = newValue ?? false;
                            });
                          },
                          activeColor: isChecked1 ? Colors.green : Colors.white, // Green if checked
                          checkColor: Colors.white, // White color for the check mark
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "3-hours study ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      _showMenu(context, details.globalPosition);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Second Habit Container
          Center(
            child: Container(
              width: 370,
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.5, // Adjust size to 30x30 by scaling
                        child: Checkbox(
                          value: isChecked2,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isChecked2 = newValue ?? false;
                            });
                          },
                          activeColor: isChecked2 ? Colors.green : Colors.white, // Green if checked
                          checkColor: Colors.white, // White color for the check mark
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Task\n0%",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      _showMenu(context, details.globalPosition);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
}
