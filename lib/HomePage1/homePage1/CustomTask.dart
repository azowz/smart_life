import 'package:flutter/material.dart';

class CustomTask extends StatelessWidget {
  const CustomTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: const Center(
        child: Text('This is the Custom task Page!'),
      ),
    );
  }
}



