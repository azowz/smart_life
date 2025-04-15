import 'package:final_project/CreateAccForm/SignInPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  _ResetWithEmailState createState() => _ResetWithEmailState();
}

class _ResetWithEmailState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _checkEmailAndSendReset() async {
    String email = _emailController.text.trim();

    try {
      // Check if email exists in Firestore
      var querySnapshot = await _firestore
          .collection('CreateAccount')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Email exists, send reset email
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password reset email sent! Check your inbox.')),
        );
      } else {
        // Email does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is not registered.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the SignInPage when the back arrow is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          },
        ),
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF2D3953),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'finalProject_img/Splash1.jpeg',
                height: 200,
                width: 500,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 80),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Color(0xFFF1F6F9),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F3E0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _checkEmailAndSendReset();
                  }
                },
                child: const Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  // Navigate to the SignInPage when the text is tapped
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                child: const Text(
                  'Return back to sign in',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    fontSize: 18,
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
