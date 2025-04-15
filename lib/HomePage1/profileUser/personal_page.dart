import 'package:final_project/CreateAccForm/HomePage.dart';
import 'package:final_project/HomePage1/Calnder/calendar_P.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllHabits.dart';
import 'package:final_project/HomePage1/homePage1/ViewAllTask.dart';
import 'package:final_project/HomePage1/profileUser/HelpSupportsPage.dart';
import 'package:final_project/HomePage1/profileUser/LanguagePage.dart';
import 'package:final_project/HomePage1/profileUser/TermsAndPolicies.dart';
import 'package:final_project/HomePage1/Calnder/calender_Page.dart';
import 'package:flutter/material.dart';
import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/AiChat/ai_assistant_page.dart';

import 'package:final_project/HomePage1/profileUser/EditProfile.dart';
import 'package:final_project/statistics_page.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Firebase authentication package

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
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
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  // Firebase logout function
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),  // Navigate to HomePage.dart
      );
    } catch (e) {
      // Handle errors (e.g., show a snackbar or alert)
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3953),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 166,
                color: const Color(0xFFD9D9D9),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 16,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePageFirst()),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.black),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: 105,
                height: 29,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 166 - 61,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const CircleAvatar(
                radius: 61,
                backgroundImage: AssetImage("finalProject_img/male.png"),
              ),
            ),
          ),
          
          // Productivity Hub
          Positioned(
            top: 280,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 390,
                  height: 29,
                  color: const Color(0xFF7A8194),
                  alignment: Alignment.center,
                  child: const Text(
                    'Productivity Hub',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                _buildListItem('Habit', Icons.arrow_forward, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewAllHabits()),
                  );
                }),
                _buildListItem('Task', Icons.arrow_forward, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewAllTask()),
                  );
                }),
                _buildListItem('Statistics', Icons.arrow_forward, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsPage()),
                  );
                }),
                _buildListItem('Calendar', Icons.arrow_forward, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const calendar_P()),
                  );
                }),
              ],
            ),
          ),

          // Support & About
          Positioned(
            top: 490,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 390,
                  height: 29,
                  color: const Color(0xFF7A8194),
                  alignment: Alignment.center,
                  child: const Text(
                    'Support & About',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                _buildListItem('Help & Support', Icons.arrow_forward, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpSupportsPage()),
                  );
                }),
                _buildListItem('Terms and Policies', Icons.arrow_forward, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TermsAndPolicies()),
                  );
                }),
              ],
            ),
          ),

          // Actions
          Positioned(
            top: 610,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 390,
                  height: 29,
                  color: const Color(0xFF7A8194),
                  alignment: Alignment.center,
                  child: const Text(
                    'Actions',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildListItem('Language', Icons.language, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LanguagePage()),
                  );
                }),
                _buildListItem('Darkmode', Icons.nightlight_round, () {
                  // Implement dark mode toggle functionality here
                }),
                const SizedBox(height: 1),
                // Logout Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _logout,  // Calls the logout function
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.exit_to_app, size: 24),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
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

  Widget _buildListItem(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: Color(0xFF2D3953), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
