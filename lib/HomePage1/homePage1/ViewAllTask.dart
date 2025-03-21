import 'package:flutter/material.dart';

class ViewAllTask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Tasks'),
      ),
      body: Center(
        child: Text('Here you can view all tasks'),
      ),
    );
  }
}