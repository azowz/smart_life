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
import '../../api/services/ai_feedback_service.dart';
import '../../api/models/ai_feedback.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
// Selected tab index, default is 2 (JARVIS tab)
  int _selectedIndex = 2;

// Controller for the input text field
  final TextEditingController _controller = TextEditingController();

// List of current chat messages displayed in the UI
  List<ChatMessage> messages = [];

// List to hold saved chat sessions (e.g., past conversations)
  List<Map<String, dynamic>> savedChats = [];

// Key to control the Scaffold (for opening drawer, showing snackbars, etc.)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// New chat name used when renaming a conversation
  String newChatName = '';

// Controller for renaming a saved chat
  final TextEditingController _renameController = TextEditingController();

// Loading indicator for API calls or heavy operations
  bool _isLoading = false;

// Holds the current AI interaction ID, if any
  int? _currentInteractionId;

// Temporary hardcoded user ID (should be replaced with real authenticated user ID later)
  int _userId = 1; // TODO: Replace with actual user ID from auth system

  @override
  void initState() {
    super.initState();
    _initializeChat(); // Setup first AI greeting message
    _loadSavedChats(); // Load previously saved conversations (if any)
  }

// Initializes the chat with a default AI welcome message
  void _initializeChat() {
    setState(() {
      messages = [
        ChatMessage(
          userId: _userId, // Attach message to current user
          content: 'Hello, I\'m JARVIS. How can I help you today?',
          isAiResponse: true,
          createdAt: DateTime.now(),
        )
      ];
    });
  }

  // Load user's saved chat interactions
  // Loads saved chat interactions for the current user from the backend
  Future<void> _loadSavedChats() async {
    try {
      // Start loading indicator
      setState(() {
        _isLoading = true;
      });

      print('🔄 Loading saved chats for user $_userId');

      // Fetch user's previous AI interactions from the API
      final interactions =
          await AIInteractionService.getUserInteractions(_userId);

      print('✅ Loaded ${interactions.length} interactions');

      // Update saved chats based on the API response
      setState(() {
        savedChats = interactions.map<Map<String, dynamic>>((interaction) {
          return {
            'id': interaction['interaction_id'], // Map backend field correctly
            'name': interaction['prompt'] ??
                'Unnamed Chat', // Use prompt as chat title
            'timestamp': interaction[
                'created_at'], // Store timestamp for sorting if needed
          };
        }).toList();

        _isLoading = false; // Stop loading indicator
      });
    } catch (e) {
      // On error, stop loading and show an error message
      setState(() {
        _isLoading = false;
      });
      print('❌ Error loading saved chats: $e');
      _showSnackBar('Failed to load chats: $e');
    }
  }

  // Load a specific chat history by interaction ID
  Future<void> _loadChatHistory(int interactionId) async {
    try {
      // Start loading indicator
      setState(() {
        _isLoading = true;
      });

      print('🔄 Loading chat history for interaction $interactionId');

      // Fetch messages associated with this AI interaction from API
      final response = await ChatMessageService.getMessagesByEntity(
        'ai_interaction',
        interactionId,
        skip: 0,
        limit: 100,
      );

      // Prepare a list to hold parsed chat messages
      List<ChatMessage> chatHistory = [];

      // Map each message from API response into a ChatMessage object
      for (var msg in response) {
        chatHistory.add(ChatMessage(
          messageId: msg['message_id'],
          userId:
              msg['user_id'] ?? _userId, // Fallback to current user ID if null
          content: msg['content'] ?? '', // Fallback to empty string
          isAiResponse: msg['is_ai_response'] ?? false,
          createdAt: msg['created_at'] != null
              ? DateTime.parse(msg['created_at'])
              : null, // Parse date if available
          relatedEntityId: msg['related_entity_id'],
          relatedEntityType: msg['related_entity_type'],
        ));
      }

      // Update UI with the loaded chat history
      setState(() {
        messages = chatHistory;
        _currentInteractionId = interactionId;
        _isLoading = false;
      });

      print(
          '✅ Loaded ${chatHistory.length} messages for interaction $interactionId');
    } catch (e) {
      // Handle errors gracefully
      setState(() {
        _isLoading = false;
      });
      print('❌ Error loading chat history: $e');
      _showSnackBar('Failed to load chat history: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    // ➊ إنشاء رسالة المستخدم محليًا
    final userChatMessage = ChatMessage(
      userId: _userId,
      content: userMessage,
      isAiResponse: false,
      createdAt: DateTime.now(),
      relatedEntityId: _currentInteractionId,
      relatedEntityType:
          _currentInteractionId != null ? 'ai_interaction' : null,
    );

    setState(() {
      messages.add(userChatMessage);
      _isLoading = true;
    });

    try {
      // ➋ إذا كانت محادثة جديدة، أنشئ interaction جديد
      if (_currentInteractionId == null) {
        final interactionData = {
          'user_id': _userId,
          'prompt': userMessage,
          'interaction_type': 'chat',
        };

        final interaction =
            await AIInteractionService.createInteraction(interactionData);

        _currentInteractionId = interaction['interaction_id'];

        final updatedUserMessage = userChatMessage.copyWith(
          relatedEntityId: _currentInteractionId,
          relatedEntityType: 'ai_interaction',
        );

        final messageData = {
          'user_id': updatedUserMessage.userId,
          'content': updatedUserMessage.content,
          'is_ai_response': updatedUserMessage.isAiResponse,
          'related_entity_id': updatedUserMessage.relatedEntityId,
          'related_entity_type': updatedUserMessage.relatedEntityType,
        };

        await ChatMessageService.createChatMessage(messageData);

        setState(() {
          savedChats.add({
            'id': _currentInteractionId,
            'name': interaction['prompt'] ?? userMessage,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      } else {
        // ➌ إذا كانت محادثة موجودة، احفظ فقط رسالة المستخدم
        final messageData = {
          'user_message': userMessage, // ✅ هذا المطلوب
          'user_id': userChatMessage.userId,
          'content': userChatMessage.content,
          'is_ai_response': userChatMessage.isAiResponse,
          'related_entity_id': userChatMessage.relatedEntityId,
          'related_entity_type': userChatMessage.relatedEntityType,
        };

        await ChatMessageService.createChatMessage(messageData);
      }

      // ➍ تجهيز بيانات إكمال التفاعل (لا ترسل user_message هنا!)
      final completionData = {
        'user_message': userMessage, // ✅ أضف هذا السطر
        'response': null,
        'processing_time': null,
        'tokens_used': null,
        'was_successful': true
      };

      // ✅ طباعة البيانات للتأكد مما يُرسل
      print('🟣 Sending completionData to backend: $completionData');

      // ➎ طلب إكمال التفاعل من السيرفر
      final response = await AIInteractionService.completeInteraction(
        _currentInteractionId!,
        completionData,
      );

      final aiResponseContent =
          response['response'] ?? "I'm sorry, I don't have a response.";

      final aiResponseMessage = ChatMessage(
        userId: _userId,
        content: aiResponseContent,
        isAiResponse: true,
        createdAt: DateTime.now(),
        relatedEntityId: _currentInteractionId,
        relatedEntityType: 'ai_interaction',
      );

      final aiMessageData = {
        'user_id': _userId,
        'content': aiResponseMessage.content,
        'is_ai_response': true,
        'related_entity_id': aiResponseMessage.relatedEntityId,
        'related_entity_type': aiResponseMessage.relatedEntityType,
      };

      await ChatMessageService.createChatMessage(aiMessageData);

      setState(() {
        messages.add(aiResponseMessage);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error in _sendMessage: $e');

      setState(() {
        messages.add(ChatMessage(
          userId: _userId,
          content: "I'm having trouble connecting. Please try again later.",
          isAiResponse: true,
          createdAt: DateTime.now(),
        ));
        _isLoading = false;
      });

      _showSnackBar('Error: $e');
    }
  }

  // Method to submit feedback
  Future<void> _submitFeedback(int rating, String? feedbackText) async {
    if (_currentInteractionId == null) {
      _showSnackBar('No active conversation to rate');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Create feedback data matching the AIFeedbackCreate schema
      final feedbackData = {
        'interaction_id': _currentInteractionId!,
        'user_id': _userId,
        'rating': rating,
        if (feedbackText != null && feedbackText.isNotEmpty)
          'feedback_text': feedbackText,
      };

      await AIFeedbackService.createFeedback(feedbackData);

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Thank you for your feedback!');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error submitting feedback: $e');
      _showSnackBar('Failed to submit feedback: $e');
    }
  }

  // Show feedback dialog
  void _showFeedbackDialog() {
    if (_currentInteractionId == null) {
      _showSnackBar('Please start a conversation first');
      return;
    }

    int selectedRating = 0;
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate this conversation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How would you rate your experience with JARVIS?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    decoration: const InputDecoration(
                      hintText: 'Additional comments (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedRating > 0) {
                      _submitFeedback(selectedRating, feedbackController.text);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a rating')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
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
              // Add feedback option when there's an active conversation
              if (_currentInteractionId != null)
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Rate Conversation'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFeedbackDialog();
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

          // Add a feedback button if there's an active conversation
          if (_currentInteractionId != null)
            Positioned(
              top: 166 + 16, // Below the avatar
              right: 16,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.star, size: 16),
                label: const Text('Rate'),
                onPressed: _showFeedbackDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(80, 36),
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
