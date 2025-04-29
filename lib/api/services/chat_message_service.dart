import '../api_client.dart';
import 'dart:convert';

class ChatMessageService {
  /// Create a new chat message
  static Future<Map<String, dynamic>> createChatMessage(
      Map<String, dynamic> messageData) async {
    final response = await ApiClient.post('/chat-messages/', messageData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create chat message: ${response.body}');
    }
  }

  /// Get a chat message by ID
  static Future<Map<String, dynamic>> getMessageById(int messageId) async {
    final response = await ApiClient.get('/chat-messages/$messageId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Chat message not found');
    }
  }

  /// Update a chat message
  static Future<Map<String, dynamic>> updateChatMessage(
      int messageId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put('/chat-messages/$messageId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update chat message: ${response.body}');
    }
  }

  /// Delete a chat message
  static Future<void> deleteChatMessage(int messageId) async {
    final response = await ApiClient.delete('/chat-messages/$messageId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete chat message');
    }
  }

  /// Get all chat messages for a user
  static Future<List<dynamic>> getUserMessages(int userId,
      {int skip = 0, int limit = 100}) async {
    final response = await ApiClient.get(
        '/chat-messages/user/$userId?skip=$skip&limit=$limit');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user messages');
    }
  }

  /// Get all chat messages linked to an entity
  static Future<List<dynamic>> getMessagesByEntity(
      String entityType, int entityId,
      {int skip = 0, int limit = 100}) async {
    final response = await ApiClient.get(
        '/chat-messages/entity/$entityType/$entityId?skip=$skip&limit=$limit');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch messages by entity');
    }
  }
}
