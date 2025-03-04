import 'package:final_project/HomePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/calendar_page.dart';
import 'package:final_project/HomePage1/personal_page.dart';
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
  int _selectedIndex = 2; // AI Assistant tab by default

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // All five buttons show labels
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navigation logic
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePageFirst()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const StatisticsPage()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            );
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const PersonalPage()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'statistics',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'finalProject_img/ai.png',
              width: 50,
              height: 50,
            ),
            label: 'AI assistant',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}