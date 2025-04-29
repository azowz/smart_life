// lib/api/services/chat_message_service.dart

import 'dart:convert';
import '../api_client.dart';

class ChatMessageService {
  /// Create a new chat message
  static Future<Map<String, dynamic>> createChatMessage(
      Map<String, dynamic> messageData) async {
    try {
      // Verify required fields based on ChatMessageCreate schema
      if (!messageData.containsKey('user_id')) {
        throw Exception('user_id is required for chat message');
      }

      if (!messageData.containsKey('content')) {
        throw Exception('content is required for chat message');
      }

      // Set default values for optional fields if needed
      if (!messageData.containsKey('is_ai_response')) {
        messageData['is_ai_response'] = false;
      }

      // Log for debugging
      print('Creating chat message with data: $messageData');

      final response = await ApiClient.post('/chat-messages/', messageData);

      if (response.statusCode == 201) {
        print('✅ Chat message created successfully');
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to create chat message: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to create chat message: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating chat message: $e');
      rethrow;
    }
  }

  /// Get a chat message by ID
  static Future<Map<String, dynamic>> getMessageById(int messageId) async {
    try {
      final response = await ApiClient.get('/chat-messages/$messageId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to get message: [${response.statusCode}] ${response.body}');
        throw Exception('Chat message not found');
      }
    } catch (e) {
      print('❌ Error getting message: $e');
      rethrow;
    }
  }

  /// Update a chat message
  static Future<Map<String, dynamic>> updateChatMessage(
      int messageId, Map<String, dynamic> updates) async {
    try {
      // Ensure content is provided if updating
      if (updates.isEmpty ||
          (!updates.containsKey('content') &&
              !updates.containsKey('is_ai_response'))) {
        throw Exception(
            'At least content or is_ai_response must be provided for update');
      }

      print('Updating message $messageId with data: $updates');

      final response =
          await ApiClient.put('/chat-messages/$messageId', updates);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to update message: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to update chat message: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating message: $e');
      rethrow;
    }
  }

  /// Delete a chat message
  static Future<void> deleteChatMessage(int messageId) async {
    try {
      final response = await ApiClient.delete('/chat-messages/$messageId');

      if (response.statusCode != 200) {
        print(
            '❌ Failed to delete message: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to delete chat message');
      }
      print('✅ Chat message deleted successfully');
    } catch (e) {
      print('❌ Error deleting message: $e');
      rethrow;
    }
  }

  /// Get all chat messages for a user
  static Future<List<dynamic>> getUserMessages(int userId,
      {int skip = 0, int limit = 100}) async {
    try {
      final response = await ApiClient.get(
          '/chat-messages/user/$userId?skip=$skip&limit=$limit');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to get user messages: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to fetch user messages');
      }
    } catch (e) {
      print('❌ Error getting user messages: $e');
      rethrow;
    }
  }

  /// Get all chat messages linked to an entity
  static Future<List<dynamic>> getMessagesByEntity(
      String entityType, int entityId,
      {int skip = 0, int limit = 100}) async {
    try {
      final response = await ApiClient.get(
          '/chat-messages/entity/$entityType/$entityId?skip=$skip&limit=$limit');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to get entity messages: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to fetch messages by entity');
      }
    } catch (e) {
      print('❌ Error getting entity messages: $e');
      rethrow;
    }
  }
}
