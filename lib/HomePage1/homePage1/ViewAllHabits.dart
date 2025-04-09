import 'package:flutter/material.dart';


class ViewAllHabits extends StatelessWidget {
  const ViewAllHabits({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View All Habits"),
      ),
      body: const Center(
        child: Text("List of all habits..."),
      ),
    );
  }
}
