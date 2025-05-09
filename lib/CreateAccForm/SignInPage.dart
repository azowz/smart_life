import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/api/services/auth_service.dart';
import 'package:final_project/api/api_config.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscureText = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username or email';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Call AuthService to login with proper form data
      await AuthService.login(
        username: username,
        password: password,
      );

      // Check if token was successfully set
      if (ApiConfig.authToken != null) {
        // Navigate to HomePageFirst on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageFirst()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed: No token received')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3953),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'finalProject_img/Splash1.jpeg',
                  height: 200,
                  width: 400,
                ),
              ),
              const SizedBox(height: 100),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      validator: _validateInput,
                      decoration: const InputDecoration(
                        labelText: 'Username or Email',
                        filled: true,
                        fillColor: Color(0xFFF1F6F9),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: const Color(0xFFF1F6F9),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(" ",
                              style: TextStyle(color: Colors.white)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgetpassword');
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F3E0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        onPressed: _isLoading ? null : _signIn,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black54),
                              )
                            : const Text(
                                "Log In",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(color: Colors.white)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              "Register Now",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
