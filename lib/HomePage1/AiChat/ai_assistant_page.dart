import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:final_project/HomePage1/profileUser/personal_page.dart';
import 'package:final_project/HomePage1/Calnder/calender_Page.dart';
import 'package:final_project/HomePage1/statistics/statistics_page.dart';
import 'package:flutter/material.dart';
// Import your existing ChatMessage model
import '../../api/models/chat_message.dart';
// Import your API services
import '../../api/services/chat_message_service.dart';
import '../../api/services/ai_interaction_service.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  int _selectedIndex = 2; // Set to 2 for JARVIS tab
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> messages = [];
  List<Map<String, dynamic>> savedChats = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String newChatName = '';
  final TextEditingController _renameController = TextEditingController();
  bool _isLoading = false;
  int? _currentInteractionId;
  int _userId = 1; // Replace with actual user ID from auth system

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _loadSavedChats();
  }

  void _initializeChat() {
    setState(() {
      // Create initial greeting message from AI - FIXED: use valid user ID
      messages = [
        ChatMessage(
          userId: _userId, // Using current user ID instead of 0
          content: 'Hello, I\'m JARVIS. How can I help you today?',
          isAiResponse: true,
          createdAt: DateTime.now(),
        )
      ];
    });
  }

  // Load user's saved chat interactions
  Future<void> _loadSavedChats() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading saved chats for user $_userId');

      // Get user's previous interactions from API
      final interactions =
          await AIInteractionService.getUserInteractions(_userId);

      print('Loaded ${interactions.length} interactions');

      setState(() {
        savedChats = interactions.map<Map<String, dynamic>>((interaction) {
          // Use the correct field names from the backend schema
          return {
            'id': interaction[
                'interaction_id'], // Field from AIInteractionResponse
            'name': interaction['prompt'] ??
                'Unnamed Chat', // Use prompt instead of title
            'timestamp': interaction['created_at'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading saved chats: $e');
      _showSnackBar('Failed to load chats: $e');
    }
  }

  // Load a specific chat history
  Future<void> _loadChatHistory(int interactionId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading chat history for interaction $interactionId');

      // Get messages for this interaction from API
      final response = await ChatMessageService.getMessagesByEntity(
          'ai_interaction', interactionId,
          skip: 0, limit: 100);

      List<ChatMessage> chatHistory = [];
      for (var msg in response) {
        // Convert API response to ChatMessage objects
        chatHistory.add(ChatMessage(
          messageId: msg['message_id'],
          userId: msg['user_id'] ?? _userId, // Default to current user if null
          content: msg['content'] ?? '',
          isAiResponse: msg['is_ai_response'] ?? false,
          createdAt: msg['created_at'] != null
              ? DateTime.parse(msg['created_at'])
              : null,
          relatedEntityId: msg['related_entity_id'],
          relatedEntityType: msg['related_entity_type'],
        ));
      }

      setState(() {
        messages = chatHistory;
        _currentInteractionId = interactionId;
        _isLoading = false;
      });

      print(
          'Loaded ${chatHistory.length} messages for interaction $interactionId');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading chat history: $e');
      _showSnackBar('Failed to load chat history: $e');
    }
  }

  // Send message to AI and get response - FIXED: uses valid user IDs for AI messages
  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    // Create a user message
    final userChatMessage = ChatMessage(
      userId: _userId,
      content: userMessage,
      isAiResponse: false,
      createdAt: DateTime.now(),
      relatedEntityId: _currentInteractionId,
      relatedEntityType:
          _currentInteractionId != null ? 'ai_interaction' : null,
    );

    // Add user message to UI immediately
    setState(() {
      messages.add(userChatMessage);
      _isLoading = true;
    });

    try {
      // Create a new interaction if this is a new chat
      if (_currentInteractionId == null) {
        print('Creating new AI interaction');

        // Create proper interaction data matching backend schema
        final interactionData = {
          'user_id': _userId,
          'prompt': userMessage, // Required field in schema
          'interaction_type': 'chat', // Required enum value
        };

        final interaction =
            await AIInteractionService.createInteraction(interactionData);

        print('Created interaction: $interaction');

        // Get the interaction_id field name from backend
        _currentInteractionId = interaction['interaction_id'];

        // Update the user message with the entity ID
        final updatedUserMessage = userChatMessage.copyWith(
          relatedEntityId: _currentInteractionId,
          relatedEntityType: 'ai_interaction',
        );

        // Save user message to database with proper schema fields
        final messageData = {
          'user_id': updatedUserMessage.userId,
          'content': updatedUserMessage.content,
          'is_ai_response': updatedUserMessage.isAiResponse,
          'related_entity_id': updatedUserMessage.relatedEntityId,
          'related_entity_type': updatedUserMessage.relatedEntityType,
        };

        await ChatMessageService.createChatMessage(messageData);

        // Add this chat to saved chats
        setState(() {
          savedChats.add({
            'id': _currentInteractionId,
            'name': interaction['prompt'] ?? userMessage,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      } else {
        // Save user message to database with existing interaction
        final messageData = {
          'user_id': userChatMessage.userId,
          'content': userChatMessage.content,
          'is_ai_response': userChatMessage.isAiResponse,
          'related_entity_id': userChatMessage.relatedEntityId,
          'related_entity_type': userChatMessage.relatedEntityType,
        };

        await ChatMessageService.createChatMessage(messageData);
      }

      // Create completion data for AI response
      final completionData = {
        'response': userMessage,
        'processing_time': 1,
        'tokens_used': 10,
        'was_successful': true
      };

      // Get AI response from API
      final response = await AIInteractionService.completeInteraction(
          _currentInteractionId!, completionData);

      // Get the response from the completed interaction
      final aiResponseContent =
          response['response'] ?? "I'm sorry, I don't have a response.";

      // Create AI response message - FIXED: use valid user ID
      final aiResponseMessage = ChatMessage(
        userId: _userId, // Using current user ID for AI messages (not 0)
        content: aiResponseContent,
        isAiResponse: true,
        createdAt: DateTime.now(),
        relatedEntityId: _currentInteractionId,
        relatedEntityType: 'ai_interaction',
      );

      // Save AI response to database with valid user ID
      final aiMessageData = {
        'user_id': _userId, // Valid user ID that exists in the database
        'content': aiResponseMessage.content,
        'is_ai_response': aiResponseMessage.isAiResponse,
        'related_entity_id': aiResponseMessage.relatedEntityId,
        'related_entity_type': aiResponseMessage.relatedEntityType,
      };

      await ChatMessageService.createChatMessage(aiMessageData);

      // Add AI response to UI
      setState(() {
        messages.add(aiResponseMessage);
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _sendMessage: $e');

      // Handle errors gracefully - FIXED: use valid user ID
      setState(() {
        messages.add(ChatMessage(
          userId: _userId, // Valid user ID for error messages too
          content: "I'm having trouble connecting. Please try again later.",
          isAiResponse: true,
          createdAt: DateTime.now(),
        ));
        _isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  // Helper method to create AI messages consistently
  ChatMessage _createAiMessage(String content,
      {int? relatedEntityId, String? relatedEntityType}) {
    return ChatMessage(
      userId: _userId, // Use valid user ID
      content: content,
      isAiResponse: true,
      createdAt: DateTime.now(),
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Send Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Add photo functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Send Voice'),
                onTap: () {
                  Navigator.pop(context);
                  // Add voice functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Suggested Questions'),
                onTap: () {
                  Navigator.pop(context);
                  _showSuggestedQuestions();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuggestedQuestions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Try asking JARVIS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSuggestion('What can you help me with?'),
              _buildSuggestion('Tell me about my upcoming tasks'),
              _buildSuggestion('How\'s my progress this week?'),
              _buildSuggestion('Do I have any appointments today?'),
              _buildSuggestion('Set a reminder for my meeting'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestion(String text) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _controller.text = text;
        _sendMessage();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.arrow_right, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
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
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Saved Chats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : savedChats.isEmpty
                        ? const Center(child: Text("No saved chats yet"))
                        : ListView.builder(
                            itemCount: savedChats.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(savedChats[index]['name']),
                                subtitle: Text(_formatDateTime(
                                    savedChats[index]['timestamp'])),
                                onTap: () {
                                  _loadChatHistory(savedChats[index]['id']);
                                  Navigator.pop(context);
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showRenameDialog(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _showDeleteConfirmation(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _startNewChat();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Start New Chat'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown date';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _startNewChat() {
    setState(() {
      // FIXED: use valid user ID for initial AI message
      messages = [
        ChatMessage(
          userId: _userId, // Using current user ID
          content: 'Hello, I\'m JARVIS. How can I help you today?',
          isAiResponse: true,
          createdAt: DateTime.now(),
        )
      ];
      _currentInteractionId = null;
    });
  }

  void _showRenameDialog(int index) {
    _renameController.text = savedChats[index]['name'];
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
              onPressed: () async {
                try {
                  // Get the new name
                  final newName = _renameController.text.trim();

                  // Convert to prompt field for the API
                  final updates = {'prompt': newName};

                  // Update via API
                  await AIInteractionService.updateInteraction(
                    savedChats[index]['id'],
                    updates,
                  );

                  // Update the UI
                  setState(() {
                    savedChats[index]['name'] = newName;
                  });

                  Navigator.pop(context);
                  _showSnackBar('Chat renamed successfully');
                } catch (e) {
                  print('Failed to rename chat: $e');
                  _showSnackBar('Failed to rename chat: $e');
                  Navigator.pop(context);
                }
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
              onPressed: () async {
                try {
                  final chatId = savedChats[index]['id'];

                  // Delete the interaction
                  await AIInteractionService.deleteInteraction(chatId);

                  setState(() {
                    savedChats.removeAt(index);
                  });

                  // If we're currently viewing this chat, start a new one
                  if (_currentInteractionId == chatId) {
                    _startNewChat();
                  }

                  Navigator.pop(context);
                  _showSnackBar('Chat deleted successfully');
                } catch (e) {
                  print('Failed to delete chat: $e');
                  Navigator.pop(context);
                  _showSnackBar('Failed to delete chat: $e');
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF2D3953),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background header and content
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
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

          // Profile avatar
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

          // Chat input box at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                      backgroundColor: Colors.blue,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat messages area
          Positioned(
            top: 166 + 80,
            left: 16,
            right: 16,
            bottom: 80,
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      "Start a conversation with JARVIS",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    reverse: false,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                          left: !messages[index].isAiResponse ? 40 : 0,
                          right: !messages[index].isAiResponse ? 0 : 40,
                          top: 8,
                          bottom: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !messages[index].isAiResponse
                              ? Colors.blue[400]
                              : const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messages[index].content,
                              style: TextStyle(
                                color: !messages[index].isAiResponse
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            if (messages[index].createdAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatMessageTime(
                                      messages[index].createdAt!),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: !messages[index].isAiResponse
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Loading indicator (shown when initializing or fetching data)
          if (_isLoading && messages.isEmpty)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: 'Statistics'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'JARVIS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Today, show time only
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Another day, show date and time
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
