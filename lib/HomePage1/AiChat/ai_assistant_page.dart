import 'package:final_project/HomePage1/calendar_page.dart';
import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/HomePage1/statistics_page.dart';
import 'package:flutter/material.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  int _selectedIndex = 0;
  TextEditingController _controller = TextEditingController();
  List<String> messages = ['Hello, how can I help you?']; // Default message from AI
  List<Map<String, dynamic>> savedChats = []; // List to save chats (with a name for each chat)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String newChatName = '';

  // Function to send text messages
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add(_controller.text); // Add user's message to the list
        // Only save chat when it's a new one
        if (savedChats.isEmpty || savedChats.last['name'] != newChatName) {
          savedChats.add({
            'name': newChatName.isEmpty ? 'Chat ${savedChats.length + 1} ${messages[0]}' : newChatName,
            'messages': List.from(messages), // Save the current chat with its name
          });
        }
        _controller.clear(); // Clear the text field after sending
      });
    }
  }

  // Function to show the "Send Photo" and "Add Voice" options
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Send Photo'),
                onTap: () {
                  // Implement photo sending functionality here
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.mic),
                title: Text('Add Voice'),
                onTap: () {
                  // Implement voice functionality here
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to navigate between pages (BottomNavigationBar)
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
      transitionDuration: const Duration(milliseconds: 200), // Speed up the transition
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child); // Smooth fade transition
      },
    ));
  }

  // Function to show the saved chats in a menu
  void _showSavedChatsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MenuSaveChat(savedChats: savedChats);
      },
    );
  }

  // Function to create a new chat
  void _startNewChat() {
    setState(() {
      newChatName = 'Chat ${savedChats.length + 1}'; // Give the new chat a unique name
      messages.clear(); // Clear the current messages for a new chat
    });
  }

  // Function to clear chat and save
  void _clearChatAndSave() {
    setState(() {
      savedChats.add({
        'name': newChatName.isEmpty ? 'Chat ${savedChats.length + 1} ${messages[0]}' : newChatName,
        'messages': List.from(messages),
      });
      messages.clear(); // Clear the current chat after saving
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF2D3953),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 166,
                color: const Color(0xFFD9D9D9),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 16,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black), // Restoring the back arrow
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePageFirst()),
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
                    const Text(
                      "AI JARVIS",
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
                          icon: const Icon(Icons.menu, color: Colors.black), // Changed to menu icon
                          onPressed: _showSavedChatsMenu, // Show saved chats menu
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
              const SizedBox(height: 80),
            ],
          ),
          Positioned(
            top: 166 - 61,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: const CircleAvatar(
                radius: 61,
                backgroundImage: AssetImage("finalProject_img/ai.png"),
              ),
            ),
          ),
          // Chat Input Section
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _showMoreOptions,
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.send, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Messages List Section
          Positioned(
            top: 166 + 80,
            left: 16,
            right: 16,
            bottom: 80,
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9), // All messages have the same background color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    messages[index],
                    style: const TextStyle(color: Colors.black), // Text color set to black
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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

class MenuSaveChat extends StatelessWidget {
  final List<Map<String, dynamic>> savedChats;
  const MenuSaveChat({super.key, required this.savedChats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Saved Chats",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: savedChats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(savedChats[index]['name']), // Show the name of each saved chat
                  onTap: () {
                    // Show the selected saved chat here
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Create a new chat and save the current one
              Navigator.pop(context); // Close the menu
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('New Chat'),
          ),
        ],
      ),
    );
  }
}
