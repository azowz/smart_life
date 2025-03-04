import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/CreateAccForm/SignUpPage3.dart';
import 'package:flutter/material.dart';

class SignUpPage2 extends StatefulWidget {
  final String username;

  const SignUpPage2({super.key, required this.username});

  @override
  _SignUpPage2State createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final Set<String> _selectedHabits = {};

  void _toggleSelection(String habit) {
    setState(() {
      if (_selectedHabits.contains(habit)) {
        _selectedHabits.remove(habit);
      } else {
        _selectedHabits.add(habit);
      }
    });
  }

  void _submitForm() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference habitsRef = firestore.collection('habits_user');

    for (String habit in _selectedHabits) {
      await habitsRef.add({
        'username': widget.username,
        'nameHabits': habit,
        'date': DateTime.now().toString(),
        'details': "265", // Placeholder, update as needed
        'goal': 255, // Placeholder, update as needed
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage3(
          username: widget.username,
          selectedHabits: _selectedHabits,
        ),
      ),
    );
  }

  Widget habitContainer(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _toggleSelection(label),
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 2,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedHabits.contains(label) ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Choose your first habits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  'You may add more habits later',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  habitContainer(Icons.local_drink, 'Drink Water'),
                  habitContainer(Icons.directions_run, 'Run'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  habitContainer(Icons.school, 'Study'),
                  habitContainer(Icons.book, 'Journal'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  habitContainer(Icons.bookmark, 'Read Book'),
                  habitContainer(Icons.bed, 'Sleep'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  habitContainer(Icons.pool, 'Swimming'),
                ],
              ),
              const SizedBox(height: 110),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F3E0),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    minimumSize: const Size(345, 52),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
