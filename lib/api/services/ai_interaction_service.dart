// lib/api/services/ai_interaction_service.dart

import 'dart:convert';
import '../api_client.dart';

class AIInteractionService {
  /// Start a new interaction
  static Future<Map<String, dynamic>> createInteraction(
      Map<String, dynamic> interactionData) async {
    try {
      // Ensure required fields match the AIInteractionCreate schema
      if (!interactionData.containsKey('user_id')) {
        throw Exception('user_id is required for AI interaction');
      }

      // Use 'title' as 'prompt' if needed
      if (interactionData.containsKey('title') &&
          !interactionData.containsKey('prompt')) {
        interactionData['prompt'] = interactionData['title'];
        interactionData.remove('title');
      }

      // Ensure prompt is present
      if (!interactionData.containsKey('prompt')) {
        interactionData['prompt'] = 'New conversation';
      }

      // Default interaction type
      interactionData.putIfAbsent('interaction_type', () => 'chat');

      // Remove fields not defined in schema
      interactionData.remove('status');

      print('Creating AI interaction with data: $interactionData');

      final response =
          await ApiClient.post('/ai-interactions/', interactionData);

      if (response.statusCode == 201) {
        print('✅ AI interaction created successfully');
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to create AI interaction: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to create AI interaction: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating interaction: $e');
      rethrow;
    }
  }

  /// Complete an interaction (no need to send response — backend generates it)
  static Future<Map<String, dynamic>> completeInteraction(
      int interactionId, Map<String, dynamic> completionData) async {
    try {
      // Required fields for completion
      completionData.putIfAbsent('user_message', () => 'No message');
      completionData.putIfAbsent('processing_time', () => 1);
      completionData.putIfAbsent('tokens_used', () => 10);
      completionData.putIfAbsent('was_successful', () => true);

      print('Completing interaction $interactionId with data: $completionData');

      final response = await ApiClient.put(
          '/ai-interactions/$interactionId/complete', completionData);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to complete interaction: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to complete AI interaction: ${response.body}');
      }
    } catch (e) {
      print('❌ Error completing interaction: $e');
      rethrow;
    }
  }

  /// Get all interactions for a specific user
  static Future<List<dynamic>> getUserInteractions(int userId,
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await ApiClient.get(
          '/ai-interactions/user/$userId?limit=$limit&offset=$offset');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to get user interactions: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to fetch user interactions');
      }
    } catch (e) {
      print('❌ Error getting user interactions: $e');
      rethrow;
    }
  }

  /// Get statistics for interactions
  static Future<Map<String, dynamic>> getInteractionStats(
      {int? userId, int days = 30}) async {
    try {
      String endpoint = '/ai-interactions/stats?days=$days';
      if (userId != null) endpoint += '&user_id=$userId';

      final response = await ApiClient.get(endpoint);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to get interaction stats: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to fetch interaction statistics');
      }
    } catch (e) {
      print('❌ Error getting interaction stats: $e');
      rethrow;
    }
  }

  /// Delete an interaction
  static Future<void> deleteInteraction(int interactionId) async {
    try {
      final response =
          await ApiClient.delete('/ai-interactions/$interactionId');

      if (response.statusCode != 200) {
        print(
            '❌ Failed to delete interaction: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to delete AI interaction');
      }
      print('✅ AI interaction deleted successfully');
    } catch (e) {
      print('❌ Error deleting interaction: $e');
      rethrow;
    }
  }

  /// Update an existing interaction
  static Future<Map<String, dynamic>> updateInteraction(
      int interactionId, Map<String, dynamic> updates) async {
    try {
      // Use 'title' as 'prompt' if needed
      if (updates.containsKey('title') && !updates.containsKey('prompt')) {
        updates['prompt'] = updates['title'];
        updates.remove('title');
      }

      print('Updating interaction $interactionId with data: $updates');

      final response =
          await ApiClient.put('/ai-interactions/$interactionId', updates);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to update interaction: [${response.statusCode}] ${response.body}');
        throw Exception('Failed to update AI interaction: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating interaction: $e');
      rethrow;
    }
  }

  /// Get a specific interaction by ID
  static Future<Map<String, dynamic>> getInteractionById(
      int interactionId) async {
    try {
      final response = await ApiClient.get('/ai-interactions/$interactionId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to get interaction: [${response.statusCode}] ${response.body}');
        throw Exception('Interaction not found');
      }
    } catch (e) {
      print('❌ Error getting interaction: $e');
      rethrow;
    }
  }
}
