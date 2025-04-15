import 'package:flutter/material.dart';




class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3953),
      body: Stack(
        children: [
          // Top Right Circle Image
          const Positioned(
            left: 292,
            top: 82,
            child: CircleAvatar(
              radius: 37.5,
              backgroundImage: AssetImage('finalProject_img/female2.png'),
            ),
          ),

          // Top Left Image
          Positioned(
            left: 116,
            top: 80,
            child: SizedBox(
              width: 300, // Increased from 140
              height: 150, // Increased from 40
              child: Image.asset(
                'finalProject_img/chat.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Middle Left Circle Image
          const Positioned(
            left: 51,
            top: 176,
            child: CircleAvatar(
              radius: 37.5,
              backgroundImage: AssetImage('finalProject_img/shayeb.png'),
            ),
          ),

          // Middle Right Image
          Positioned(
            left: 65,
            top: 175,
            child: SizedBox(
              width: 300, // Increased from 140
              height: 150, // Increased from 40
              child: Image.asset(
                'finalProject_img/chat.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Bottom Right Circle Image
          const Positioned(
            left: 292,
            top: 251,
            child: CircleAvatar(
              radius: 37.5,
              backgroundImage: AssetImage('finalProject_img/male.png'),
            ),
          ),

          // Bottom Left Image
          Positioned(
            left: 117,
            top: 255,
            child: SizedBox(
              width: 300, // Increased from 140
              height: 150, // Increased from 40
              child: Image.asset(
                'finalProject_img/chat.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Rest of the code remains exactly the same...
          // "Create Good Habit" Text
          const Positioned(
            left: 35,
            top: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFFF1F6F9),
                  ),
                ),
                Text(
                  'Good Habit',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFFF1F6F9),
                  ),
                ),
              ],
            ),
          ),

          // Description Text
          const Positioned(
            left: 35,
            top: 413,
            child: SizedBox(
              width: 346,
              child: Text(
                'Change your life by gradually adding new healthy habits and tasks, and sticking to them.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFF1F6F9),
                ),
              ),
            ),
          ),

          // Pagination Dots
          Positioned(
            left: 42,
            top: 479,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Sign In Button
          Positioned(
            left: 20,
            top: 552,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F3E0),
                fixedSize: const Size(160, 50),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              child: Text('Sign In',
              style: TextStyle(
                        fontSize: 17,
                      ),),
            ),
          ),

          // Sign Up Button
          Positioned(
            left: 235,
            top: 553,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F6F9),
                fixedSize: const Size(160, 50),
                
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child:  Text('Sign Up',
              style: TextStyle(
                        fontSize: 17,
                      ),),
            ),
          ),

          // Social Media Buttons
          
          Positioned(
            left: 25,
            top: 620,
            child: SizedBox(
              width: 370,
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apple Button - now larger
          Positioned(
            left: 25,
            top: 655,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F6F9),
                fixedSize: const Size(370, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.apple, color: Colors.black, size: 30,),
              label: const Text(
                'Continue with Apple',
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () {},
            ),
          ),

          // Google Button - now larger
          Positioned(
            left: 25,
            top: 720,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F6F9),
                fixedSize: const Size(370, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.black, size: 35,),
              label: const Text(
                'Continue with Google',
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      
    );
  }
}