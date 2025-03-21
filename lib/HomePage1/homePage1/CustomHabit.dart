import 'package:flutter/material.dart';

class CustomHabit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Habit'),
      ),
      body: Center(
        child: Text('This is the Custom Habit Page!'),
      ),
    );
  }
}