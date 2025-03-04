import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/CreateAccForm/SignUpPage2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Variables for phone authentication
  String? _verificationId;
  int? _resendToken;

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Step 1: Create user in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Step 2: Verify the phone number
        await _verifyPhoneNumber(userCredential.user!);

        // Step 3: Store additional user data in Firestore
        String userId = userCredential.user!.uid;
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection('CreateAccount').doc(userId);

        // Check if user already exists
        DocumentSnapshot userSnapshot = await userDoc.get();
        if (userSnapshot.exists) {
          // If user exists, update their data
          await userDoc.update({
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            'gender': _selectedGender,
            'password': _passwordController.text.trim(), // Avoid storing password in plain text if possible
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // If user doesn't exist, create a new user
          await userDoc.set({
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            'password': _passwordController.text.trim(), // Avoid storing password in plain text if possible
            'gender': _selectedGender,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Navigate to the next page (SignUpPage2.dart)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SignUpPage2(username: _usernameController.text),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred";
        print("FirebaseAuthException: ${e.message}");
        print("Error code: ${e.code}");
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered. Try logging in.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } on FirebaseException catch (e) {
        print("FirestoreException: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firestore error: ${e.message}')),
        );
      } catch (e) {
        print("Unknown error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  Future<void> _verifyPhoneNumber(User user) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+966${_phoneController.text.trim()}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification completed
        await user.linkWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Phone verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Save the verification ID and resend token
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
        });

        // Prompt the user to enter the SMS code
        String smsCode = await _showSmsCodeDialog();
        if (smsCode.isNotEmpty) {
          // Create a PhoneAuthCredential with the SMS code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: smsCode,
          );

          // Link the phone number to the user
          await user.linkWithCredential(credential);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<String> _showSmsCodeDialog() async {
    String smsCode = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter SMS Code'),
        content: TextField(
          onChanged: (value) {
            smsCode = value;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'SMS Code'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    return smsCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        title: const Center(
          child: Text(
            'Create Account',
            style: TextStyle(fontSize: 20),
          ),
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
                // Full Name Fields
                const Text(
                  'Full Name',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
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
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Please enter a valid last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Username Field
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
                const SizedBox(height: 20),
                // Email Field
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
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Phone Number Field
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
                const SizedBox(height: 20),
                // Password Field
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
                const SizedBox(height: 20),
                // Gender selection
                const Center(
                  child: Text(
                    'Choose your gender',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _selectGender('male'),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedGender == 'male'
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage('finalProject_img/male.png'),
                            ),
                          ),
                          const Text(
                            'Male',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: () => _selectGender('female'),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedGender == 'female'
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage('finalProject_img/female2.png'),
                            ),
                          ),
                          const Text(
                            'Female',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F3E0),
                      minimumSize: const Size(300, 50),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20),
                    ),
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
}