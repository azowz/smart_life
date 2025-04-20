import 'package:flutter/material.dart';
import 'package:final_project/ApiService.dart';
import 'package:final_project/CreateAccForm/SignUpPage2.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedGender = '';
  bool _isPasswordVisible = false;

  // Method to select gender
  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your gender')),
        );
        return;
      }

      // Show a loading indicator or snack bar to show the user is being created
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating account... Please wait')),
      );

      // Call ApiService to create a user
      bool success = await ApiService.createUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: '+966${_phoneController.text.trim()}',
        password: _passwordController.text.trim(),
        gender: _selectedGender,
      );

      // Check if the user was successfully created
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage2(username: _usernameController.text),
          ),
        );
      } else {
        // If creation failed, show an appropriate error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create account. Please check your info or try a different username/email.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        title: const Center(
          child: Text('Create Account', style: TextStyle(fontSize: 20)),
        ),
      ),
      body: Container(
        color: const Color(0xFF2D3953),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Full Name', style: TextStyle(color: Colors.white, fontSize: 16)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          filled: true,
                          fillColor: Color(0xFFF1F6F9),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Please enter a valid first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          filled: true,
                          fillColor: Color(0xFFF1F6F9),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Please enter a valid last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Username', style: TextStyle(color: Colors.white, fontSize: 16)),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Color(0xFFF1F6F9),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
                      return 'Only letters, numbers, dots, and underscores allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Email', style: TextStyle(color: Colors.white, fontSize: 16)),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Color(0xFFF1F6F9),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Phone Number', style: TextStyle(color: Colors.white, fontSize: 16)),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: Color(0xFFF1F6F9),
                    prefixText: '+966 ',
                  ),
                  maxLength: 9,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Password', style: TextStyle(color: Colors.white, fontSize: 16)),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFFF1F6F9),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  maxLength: 16,
                  validator: (value) {
                    if (value == null || value.length < 4 || value.length > 16) {
                      return 'Password must be 4–16 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text('Choose your gender', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _genderOption('male', 'finalProject_img/male.png'),
                    const SizedBox(width: 40),
                    _genderOption('female', 'finalProject_img/female2.png'),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F3E0),
                      minimumSize: const Size(300, 50),
                    ),
                    onPressed: _submitForm,
                    child: const Text('Sign Up', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gender selection button widget
  Widget _genderOption(String gender, String imagePath) {
    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedGender == gender ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(radius: 30, backgroundImage: AssetImage(imagePath)),
          ),
          Text(gender[0].toUpperCase() + gender.substring(1), style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
