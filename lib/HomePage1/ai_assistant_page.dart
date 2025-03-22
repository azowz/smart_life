import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/calendar_page.dart';
import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/HomePage1/statistics_page.dart';
import 'package:flutter/material.dart';

// import 'package:speech_to_text/speech_to_text.dart' as stt; // Commented out

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  // // Speech-to-text fields (commented out to disable microphone usage)
  // late stt.SpeechToText _speech;
  final bool _isListening =
      false; // We'll keep this, but it no longer toggles mic
  final String _transcribedText = '';

  // Bottom nav index
  int _selectedIndex = 0; // AI Assistant tab by default

  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText(); // Commented out to prevent STT init
  }

  // // Start listening (commented out so it doesn't ask for microphone)
  // Future<void> _startListening() async {
  //   bool available = await _speech.initialize(
  //     onStatus: (val) => print('onStatus: $val'),
  //     onError: (val) => print('onError: $val'),
  //   );
  //   if (available) {
  //     setState(() => _isListening = true);
  //     _speech.listen(
  //       onResult: (val) {
  //         setState(() {
  //           _transcribedText = val.recognizedWords;
  //         });
  //       },
  //     );
  //   } else {
  //     setState(() => _isListening = false);
  //     // STT not available
  //   }
  // }

  // // Stop listening (commented out so it doesn't request microphone usage)
  // void _stopListening() async {
  //   await _speech.stop();
  //   setState(() => _isListening = false);
  // }
  void _navigateToPage(int index, BuildContext context) {
    Widget page;

    switch (index) {
      case 1:
        page = const StatisticsPage();
        break;
      case 2:
        page = const AiAssistantPage();
        break;
      case 3:
        page = const CalendarPage();
        break;
      case 4:
        page = const PersonalPage();
        break;
      default:
        page = const HomePageFirst();
        break;
    }
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: 200), // Speed up the transition
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child); // Smooth fade transition
      },
    ));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant Page'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the recognized text
            Text(
              _transcribedText.isEmpty ? 'Say something...' : _transcribedText,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Mic button (now does nothing)
            ElevatedButton.icon(
              // onPressed: _isListening ? _stopListening : _startListening, // Commented out
              onPressed: () {
                // Currently does nothing since mic usage is disabled
              },
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? 'Stop' : 'Start'),
            ),
            const Spacer(),
            // Could add more AI UI elements or conversation display here...
          ],
        ),
      ),
      // Fix here: Corrected the semicolon after the body section
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
           // Handle navigation and smooth transition
          _navigateToPage(index, context);

          
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Statistics'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Assistant'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],

  
      ),
    );
  }
}