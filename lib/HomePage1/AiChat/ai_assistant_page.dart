import 'package:final_project/ApiService.dart';
import 'package:final_project/HomePage1/Calnder/calender_Page.dart';
import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/HomePage1/statistics/statistics_page.dart';
import 'package:flutter/material.dart';


class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  int _selectedIndex = 0;
  final TextEditingController _controller = TextEditingController();
List<Map<String, dynamic>> messages = [
  {'text': 'Hello, how can I help you?', 'isUser': false, 'timestamp': DateTime.now()}
];
  List<Map<String, dynamic>> savedChats = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String newChatName = '';
  final TextEditingController _renameController = TextEditingController();
  String? currentConversationId;
  bool isLoading = false;

// Update your message sending and receiving logic
Future<void> _sendMessage() async {
  if (_controller.text.isEmpty) return;

  // Create the user message object
  final userMessage = {
    'text': _controller.text,
    'isUser': true,
    'timestamp': DateTime.now().toIso8601String()
  };

  setState(() {
    messages.add(userMessage);
    isLoading = true;
    _controller.clear();
  });

  try {
    // Send just the text to the API
    final response = await ApiService.sendChatMessage(
      message: _controller.text,  // Send the raw text, not the map
      conversationId: currentConversationId,
      userId: 'current_user_id', // Replace with actual user ID
    );

    // Handle the API response
    setState(() {
      messages.add({
        'text': response['message'] ?? "I didn't get a response",
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String()
      });
      currentConversationId = response['conversation_id'] ?? currentConversationId;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      messages.add({
        'text': "Error: ${e.toString()}",
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String()
      });
      isLoading = false;
    });
  }
}

  Future<void> _startNewChat() async {
    if (messages.length > 1 || 
        (messages.isNotEmpty && messages[0]['text'] != 'Hello, how can I help you?')) {
      _saveCurrentChat();
    }

    try {
      final response = await ApiService.startNewConversation(
        userId: 'current_user_id',
      );

      setState(() {
        messages = [{'text': 'Hello, how can I help you?', 'isUser': false}];
        currentConversationId = response['conversation_id'];
        newChatName = '';
      });
    } catch (e) {
      print('Error starting new conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start new conversation')),
      );
    }
  }

Future<void> _loadConversation(String conversationId) async {
  setState(() => isLoading = true);
  
  try {
    final conversation = await ApiService.getConversation(conversationId);
    
    setState(() {
      messages = (conversation['messages'] as List).map((msg) {
        return {
          'text': msg['content'] ?? msg['text'] ?? '',
          'isUser': msg['sender'] == 'user',
          'timestamp': msg['timestamp'] != null 
             ? DateTime.parse(msg['timestamp']) 
             : DateTime.now()
        };
      }).toList();
      
      currentConversationId = conversationId;
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}'))
    );
  }
}

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Send Photo'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Send Voice'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  void _showSavedChatsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MenuSaveChat(
          savedChats: savedChats,
          onNewChat: _startNewChat,
          onChatSelected: (index) {
            _loadConversation(savedChats[index]['id']);
            Navigator.pop(context);
          },
          onRenameChat: (index) {
            _renameController.text = savedChats[index]['name'];
            _showRenameDialog(index);
          },
          onDeleteChat: (index) {
            _showDeleteConfirmation(index);
          },
        );
      },
    );
  }

  void _saveCurrentChat() {
    if (messages.isNotEmpty) {
      setState(() {
        savedChats.add({
          'id': currentConversationId,
          'name': newChatName.isEmpty ? 
            'Chat ${savedChats.length + 1}: ${messages.length > 1 ? messages[1]['text'] : messages[0]['text']}' : 
            newChatName,
          'messages': List.from(messages),
        });
      });
    }
  }

  void _showRenameDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Chat'),
          content: TextField(
            controller: _renameController,
            decoration: const InputDecoration(hintText: 'Enter new chat name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  savedChats[index]['name'] = _renameController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text('Are you sure you want to delete this chat?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  savedChats.removeAt(index);
                });
                Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat deleted')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startNewChat();
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
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                      "JARVIS",
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
                          icon: const Icon(Icons.menu, color: Colors.black),
                          onPressed: _showSavedChatsMenu,
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
                      onSubmitted: (_) => _sendMessage(),
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
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: isLoading 
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.send, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 166 + 80,
            left: 16,
            right: 16,
            bottom: 80,
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  alignment: message['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: message['isUser'] ? const Color(0xFF4A80F0) : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: message['isUser'] ? const Radius.circular(12) : Radius.zero,
                      bottomRight: message['isUser'] ? Radius.zero : const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: message['isUser'] ? Colors.white : Colors.black,
                    ),
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
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'JARVIS'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class MenuSaveChat extends StatelessWidget {
  final List<Map<String, dynamic>> savedChats;
  final VoidCallback onNewChat;
  final Function(int) onChatSelected;
  final Function(int) onRenameChat;
  final Function(int) onDeleteChat;

  const MenuSaveChat({
    super.key, 
    required this.savedChats,
    required this.onNewChat,
    required this.onChatSelected,
    required this.onRenameChat,
    required this.onDeleteChat,
  });

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
                  title: Text(savedChats[index]['name']),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'rename') {
                        onRenameChat(index);
                      } else if (value == 'delete') {
                        onDeleteChat(index);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text('Rename'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ];
                    },
                  ),
                  onTap: () {
                    onChatSelected(index);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              onNewChat();
              Navigator.pop(context);
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