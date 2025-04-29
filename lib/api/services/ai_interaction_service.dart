import '../api_client.dart';
import 'dart:convert';

class AIInteractionService {
  /// Start a new interaction
  static Future<Map<String, dynamic>> createInteraction(
      Map<String, dynamic> interactionData) async {
    final response = await ApiClient.post('/ai-interactions/', interactionData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create AI interaction: ${response.body}');
    }
  }

  /// Complete an interaction by adding response
  static Future<Map<String, dynamic>> completeInteraction(
      int interactionId, Map<String, dynamic> completionData) async {
    final response = await ApiClient.put(
        '/ai-interactions/$interactionId/complete', completionData);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to complete AI interaction: ${response.body}');
    }
  }

  /// Get user interactions
  static Future<List<dynamic>> getUserInteractions(int userId,
      {int limit = 50, int offset = 0}) async {
    final response = await ApiClient.get(
        '/ai-interactions/user/$userId?limit=$limit&offset=$offset');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user interactions');
    }
  }

  /// Get interaction statistics
  static Future<Map<String, dynamic>> getInteractionStats(
      {int? userId, int days = 30}) async {
    String endpoint = '/ai-interactions/stats?days=$days';
    if (userId != null) endpoint += '&user_id=$userId';

    final response = await ApiClient.get(endpoint);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch interaction statistics');
    }
  }
  // Extensions for the existing AIInteractionService

// These extension methods should be added to your AIInteractionService class

  /// Delete an interaction
  static Future<void> deleteInteraction(int interactionId) async {
    final response = await ApiClient.delete('/ai-interactions/$interactionId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete AI interaction');
    }
  }

  /// Update an interaction
  static Future<Map<String, dynamic>> updateInteraction(
      int interactionId, Map<String, dynamic> updates) async {
    final response =
        await ApiClient.put('/ai-interactions/$interactionId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update AI interaction: ${response.body}');
    }
  }

  /// Get interactions by category
  static Future<List<dynamic>> getInteractionsByCategory(String category,
      {int limit = 20, int offset = 0}) async {
    final response = await ApiClient.get(
        '/ai-interactions/category/$category?limit=$limit&offset=$offset');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch interactions by category');
    }
  }

  /// Get a specific interaction by ID
  static Future<Map<String, dynamic>> getInteractionById(
      int interactionId) async {
    final response = await ApiClient.get('/ai-interactions/$interactionId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Interaction not found');
    }
  }

  /// Save interaction feedback
  static Future<Map<String, dynamic>> saveInteractionFeedback(
      int interactionId, Map<String, dynamic> feedbackData) async {
    final response = await ApiClient.post(
        '/ai-interactions/$interactionId/feedback', feedbackData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to save feedback: ${response.body}');
    }
  }
}
