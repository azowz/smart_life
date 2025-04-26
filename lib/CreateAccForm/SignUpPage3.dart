import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:flutter/material.dart';
import 'package:final_project/ApiService.dart'; // Import your ApiService

class SignUpPage3 extends StatefulWidget {
  final String username;
  final Set<String> selectedHabits;

  const SignUpPage3({super.key, required this.username, required this.selectedHabits});

  @override
  _SignUpPage3State createState() => _SignUpPage3State();
}

class _SignUpPage3State extends State<SignUpPage3> {
  bool _agreeToTerms = false;
  bool _subscribeToEmails = false;
  String usernameFromDB = ""; // To hold the username fetched from DB
  Set<String> habitsFromDB = {}; // To hold the habits fetched from DB

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data (username and habits) from the backend
  Future<void> _fetchUserData() async {
  try {
    final userData = await ApiService.fetchUserData(widget.username); // Pass username here

    if (userData.isNotEmpty) {
      setState(() {
        usernameFromDB = userData['username'] ?? ''; // Default to empty string if null
        habitsFromDB = Set<String>.from(userData['habits'] ?? []); // Default to empty list if null
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user data found or user has no habits')),
      );
    }
  } catch (e) {
    // In case of an error, handle the exception and show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load user data: $e')),
    );
  }
}


  void _changeAvatar() {
    // Code to change avatar from the gallery
  }

  void _createAccount() async {
    bool success = await ApiService.createAccount(
      username: widget.username,
      habits: habitsFromDB.toList(),
      agreeToTerms: _agreeToTerms,
      subscribeToEmails: _subscribeToEmails,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePageFirst()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account creation failed. Please try again.')),
      );
    }
  }

  Widget habitContainer(String habit) {
    IconData icon;
    switch (habit) {
      case 'Drink Water':
        icon = Icons.local_drink;
        break;
      case 'Run':
        icon = Icons.directions_run;
        break;
      case 'Study':
        icon = Icons.school;
        break;
      case 'Journal':
        icon = Icons.book;
        break;
      case 'Read Book':
        icon = Icons.bookmark;
        break;
      case 'Sleep':
        icon = Icons.bed;
        break;
      case 'Swimming':
        icon = Icons.pool;
        break;
      default:
        icon = Icons.help_outline; // Default icon for unknown habits
    }

    return Container(
      width: 99,
      height: 134,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF5E8B7E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 5),
          Text(
            habit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        title: const Center(
          child: Text(
            'Create Account',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF2D3953),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 61,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 59,
                      backgroundImage: AssetImage('finalProject_img/male.png'),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _changeAvatar,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                usernameFromDB.isNotEmpty ? usernameFromDB : widget.username,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 80),
              Container(
                width: 367,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Habits are:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 20.0,
                      runSpacing: 20.0,
                      children: habitsFromDB.isNotEmpty
                          ? habitsFromDB.map((habit) {
                              return habitContainer(habit);
                            }).toList()
                          : widget.selectedHabits.map((habit) {
                              return habitContainer(habit);
                            }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreeToTerms = value!;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "By selecting 'Create Account,' you confirm that you have read and agree to the Life Organizer System's terms and conditions.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _subscribeToEmails,
                    onChanged: (bool? value) {
                      setState(() {
                        _subscribeToEmails = value!;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Optional: Email me about weekly achievement habits and goals.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 130),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F3E0),
                  minimumSize: const Size(300, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
                onPressed: _createAccount,
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
