import 'package:flutter/material.dart';

class ViewAllTask extends StatelessWidget {
  const ViewAllTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View All Tasks'),
      ),
      body: const Center(
        child: Text('Here you can view all tasks'),
      ),
    );
  }
}