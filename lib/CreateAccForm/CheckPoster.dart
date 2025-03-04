import 'package:flutter/material.dart';

class CheckPoster extends StatefulWidget {
  const CheckPoster({super.key});

  @override
  _CheckPosterState createState() => _CheckPosterState();
}

class _CheckPosterState extends State<CheckPoster> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    final String? email = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/forgetpassword');
          },
        ),
        title: const Text('Authentication'),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Verification code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We have sent the code verification to ',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              Row(
                children: [
                  Text(
                    email ?? 'your email',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/forgetpassword');
                    },
                    child: const Text(
                      'change email?',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 55,
                    child: TextFormField(
                      controller: _controllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Color(0xFFF1F6F9),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context)
                              .nextFocus(); // Move to next field
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .previousFocus(); // Move to previous field if empty
                        }
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[0-9]$').hasMatch(value)) {
                          return ' ';
                        }
                        return null;
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 60),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F3E0),
                        minimumSize: const Size(150, 50),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero, // Remove border radius
                        ),
                      ),
                      onPressed: () {
                        // Resend code logic
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black), // Change text color to white
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F3E0),
                        minimumSize: const Size(150, 50),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero, // Remove border radius
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context,
                              '/changepassword'); // Navigate to ChangePassword
                        }
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black), // Change text color to white
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
