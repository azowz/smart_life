import 'package:flutter/material.dart';

class TermsAndPolicies extends StatelessWidget {
  const TermsAndPolicies({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms And Policies'),
      ),
      body: const Center(
        child: Text('Here you can TermsAndPolicies'),
      ),
    );
  }
}