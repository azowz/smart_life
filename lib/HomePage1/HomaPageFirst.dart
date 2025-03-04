import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/HomePage1/ai_assistant_page.dart';
import 'package:final_project/HomePage1/calendar_page.dart';
import 'package:final_project/HomePage1/personal_page.dart';
import 'package:final_project/HomePage1/statistics_page.dart';
import 'ViewAllHabits.dart'; // Import the ViewAllHabits page

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

class _MyHomePageState extends State<HomePageFirst> {
  int _selectedIndex = 0;
  String _username = "";
  int completedTasks = 0;
  int totalTasks = 5; // Example total tasks count
  List<Map<String, dynamic>> _habits = []; // List to store user habits

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchHabits();
  }

  Future<void> _fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('CreateAccount')
          .doc(user.uid)
          .get();
      setState(() {
        _username = userDoc["username"] ?? "User";
      });
    }
  }

  Future<void> _fetchHabits() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot habitSnapshot = await FirebaseFirestore.instance
          .collection('habits_user')
          .where('user_id', isEqualTo: user.uid)
          .get();
      setState(() {
        _habits = habitSnapshot.docs
            .map((doc) => {
                  "name": doc["name"] ?? "No Name",
                  "details": doc["details"] ?? "No Details"
                })
            .toList();
      });
    }
  }

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
            Text("Hi, $_username", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        color: completionPercentage > 0 ? Colors.blue : Colors.black,
                        width: 3,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${completionPercentage.toInt()}%",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Your daily goals almost done!",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$completedTasks of $totalTasks Completed",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
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
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                   
                  ),
                );
              },
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
          if (index == 1) {
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
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const PersonalPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Statistics'),
          BottomNavigationBarItem(
            icon: Image(image: AssetImage('finalProject_img/ai.png'), width: 50, height: 50),
            label: 'AI Assistant',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Info'),
        ],
      ),
    );
  }
}