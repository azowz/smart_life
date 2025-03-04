import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _changePasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText1 = true;
  bool _obscureText2 = true;

  void _togglePasswordVisibility1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  void _togglePasswordVisibility2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/checkposter');
          },
        ),
        title: const Text('ChangePassword'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF2D3953),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'finalProject_img/homeScreen.png', // Replace with your image asset
                  height: 200,
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _changePasswordController,
                obscureText: _obscureText1,
                decoration: InputDecoration(
                  labelText: 'Change Password',
                  filled: true,
                  fillColor: const Color(0xFFF1F6F9),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText1
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: _togglePasswordVisibility1,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              const Text(
                'Confirm Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureText2,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: const Color(0xFFF1F6F9),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText2
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: _togglePasswordVisibility2,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid password';
                  }
                  if (value != _changePasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F3E0),
                  minimumSize: const Size(double.infinity, 50), // Ensures button and input are same size
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Remove border radius
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform password change action
                    Navigator.pushNamed(context, '/signin'); // Navigate to SignInPage
                  }
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 20, color: Colors.black), // Change text color to white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
