import 'package:final_project/HomePage1/homePage1/CustomHabit.dart';
import 'package:final_project/HomePage1/homePage1/CustomTask.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllHabits.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllTask.dart';
import 'package:final_project/HomePage1/Calnder/calender_Page.dart';
import 'package:flutter/material.dart';


import 'package:final_project/HomePage1/AiChat/ai_assistant_page.dart';

import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/HomePage1/statistics/statistics_page.dart';

class HomePageFirst extends StatefulWidget {
  const HomePageFirst({super.key});

  @override
  State<HomePageFirst> createState() => _MyHomePageState();
}

String _weekdayToString(int weekday) {
  switch (weekday) {
    case 1:
      return "Monday";
    case 2:
      return "Tuesday";
    case 3:
      return "Wednesday";
    case 4:
      return "Thursday";
    case 5:
      return "Friday";
    case 6:
      return "Saturday";
    case 7:
      return "Sunday";
    default:
      return "Unknown";
  }
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
      transitionDuration: const Duration(milliseconds: 200), // Speed up the transition
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child); // Smooth fade transition
      },
    ));
}

class _MyHomePageState extends State<HomePageFirst> {
  int _selectedIndex = 0;
  final String _username = "";
  int completedTasks = 0;
  int totalTasks = 5;
  final List<Map<String, dynamic>> _habits = [];
  bool _isChecked = false; // Track checkbox state


  

  double calculateCompletionPercentage() {
    return totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;
  }
 
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdayStr = _weekdayToString(now.weekday);
    final dateStr = "${now.day}/${now.month}/${now.year}";
    final titleString = "$weekdayStr, $dateStr";
    final double completionPercentage = calculateCompletionPercentage();

    return Scaffold(
      backgroundColor: const Color(0xFF2D3953),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D9D9),
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleString, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 5),
            Text("Hi, $_username",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.sentiment_satisfied_alt, size: 30),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mood settings coming soon!')),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: completionPercentage > 0
                            ? Colors.blue
                            : Colors.black,
                        width: 3,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${completionPercentage.toInt()}%",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Your daily goals almost done!",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$completedTasks of $totalTasks Completed",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Habit",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ViewAllHabits()),
                    );
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width *
                0.9, // Set width to 90% of screen width
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9), // Background color
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Left Section: Water Icon with Circle (2 cm)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 57.6 / 2, // 2 cm = 57.6 pixels
                        backgroundColor: Colors.blue,
                      ),
                      Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),

                // Middle Section: Text "Drink the water" and "500/500ml"
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drink the water',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '500/5000ml',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Section: Button "+" at the end with white background
                Padding(
                  padding: const EdgeInsets.only(
                      left: 85.0, right: 16.0), // Added more right padding
                  child: Align(
                    alignment:
                        Alignment.centerRight, // Align button to the right end
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the CustomHabit page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CustomHabit()), // Navigate to CustomHabit page
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .white, // Set button background color to white
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                              color: Colors.grey), // Optional border color
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Task",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ViewAllTask()),
                    );
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
            
Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9), // Background color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space items evenly
        children: [
          // Left side: Checkbox with custom size and color
        Row(
            children: [
              Transform.scale(
                scale: 30 / 24, // Scale factor to make the checkbox 30x30 (default is 24x24)
                child: Checkbox(
                  value: _isChecked, // Bind the checkbox state
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false; // Update the checkbox state
                    });
                  },
                  activeColor: Colors.green,  // Green when checked
                  checkColor: Colors.white, // White check mark
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink the tap area for a smaller button size
                ),
              ),
              const Text(
                'Take medication',
                style: TextStyle(
                  color: Colors.black, // Text color black
                ),
              ),
            ],
          ),
          
          
          // Right side: Button with updated design
          Padding(
            padding: const EdgeInsets.only(
              left: 85.0, right: 16.0, // Added more right padding
            ),
            child: Align(
              alignment: Alignment.centerRight, // Align button to the right end
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the CustomHabit page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomTask(), // Navigate to CustomHabit page
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Set button background color to white
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Colors.grey, // Optional border color
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
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
}
