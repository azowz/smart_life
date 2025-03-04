import 'package:flutter/material.dart';


class ViewAllHabits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View All Habits"),
      ),
      body: Center(
        child: Text("List of all habits..."),
      ),
    );
  }
}
