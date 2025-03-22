import 'package:final_project/CreateAccForm/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentUsername;
  String? _currentEmail;
  String? _currentPhone;

  // Function to update user information in Firestore
  Future<void> updateUserInfo() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      // Show error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields must be filled')),
      );
      return;
    }

    try {
      // Get the current user
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Get Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Get the reference to the user's document in Firestore
        DocumentReference userRef = firestore.collection('users').doc(currentUser.uid);

        // Initialize a map to store the updated data
        Map<String, dynamic> updatedData = {};

        // Check if the new values are different from the current ones
        if (_usernameController.text != _currentUsername) {
          updatedData['username'] = _usernameController.text;
        } else if (_usernameController.text == _currentUsername) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New username cannot be the same as the current one')),
          );
          return;
        }

        if (_emailController.text != _currentEmail) {
          updatedData['email'] = _emailController.text;
        } else if (_emailController.text == _currentEmail) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New email cannot be the same as the current one')),
          );
          return;
        }

        if (_phoneController.text != _currentPhone) {
          updatedData['phone'] = _phoneController.text;
        } else if (_phoneController.text == _currentPhone) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New phone number cannot be the same as the current one')),
          );
          return;
        }

        if (_passwordController.text.isNotEmpty) {
          updatedData['password'] = _passwordController.text;
        }

        if (updatedData.isNotEmpty) {
          // Update the user's data in Firestore
          await userRef.update(updatedData);

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User information updated successfully')),
          );
        } else {
          // If no data changed, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No changes were made')),
          );
        }
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user info: $e')),
      );
    }
  }

  // Function to fetch user information from Firestore
  Future<void> fetchUserInfo() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Fetch the user data from Firestore
        DocumentSnapshot userDoc = await firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          // Set the existing data to the text controllers and store the current data for comparison
          _currentUsername = userDoc['username'] ?? '';
          _currentEmail = userDoc['email'] ?? '';
          _currentPhone = userDoc['phone'] ?? '';
          
          // Prepopulate the text fields with current data
          _usernameController.text = _currentUsername!;
          _emailController.text = _currentEmail!;
          _phoneController.text = _currentPhone!;
          _passwordController.text = userDoc['password'] ?? '';  // This is sensitive data, use secure handling for passwords
        }
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user info: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();  // Fetch user info when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3953),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(  // Added SingleChildScrollView to prevent overflow
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 166,
                  color: Color(0xFFD9D9D9),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 16,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PersonalPage()),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Positioned(
                        right: 16,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            icon: Icon(Icons.settings, color: Colors.black),
                            onPressed: () {},
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80),
                SizedBox(
                  width: 120,
                  height: 29,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfile()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "Change Photo",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Username Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Color(0xFFF1F6F9),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
                            return 'Username can only contain letters, numbers, dots, and underscores';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Email Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Phone Number Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phone Number',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Password Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: const Color(0xFFF1F6F9),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        maxLength: 16,
                        validator: (value) {
                          if (value == null ||
                              value.length < 4 ||
                              value.length > 16) {
                            return 'Password must be between 4 and 16 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Update Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: updateUserInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF3F3E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 166 - 61,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: CircleAvatar(
                radius: 61,
                backgroundImage: AssetImage("finalProject_img/male.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
