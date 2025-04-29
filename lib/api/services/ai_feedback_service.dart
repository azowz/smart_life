import '../api_client.dart';
import 'dart:convert';

class AIFeedbackService {
  /// Create a new AI feedback
  static Future<Map<String, dynamic>> createFeedback(
      Map<String, dynamic> feedbackData) async {
    final response = await ApiClient.post('/ai-feedback/', feedbackData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create feedback: ${response.body}');
    }
  }

  /// Update existing feedback
  static Future<Map<String, dynamic>> updateFeedback(
      int feedbackId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put('/ai-feedback/$feedbackId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update feedback: ${response.body}');
    }
  }

  /// Delete a feedback
  static Future<void> deleteFeedback(int feedbackId) async {
    final response = await ApiClient.delete('/ai-feedback/$feedbackId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete feedback');
    }
  }

  /// Get feedback for an interaction
  static Future<List<dynamic>> getFeedbackForInteraction(
      int interactionId) async {
    final response =
        await ApiClient.get('/ai-feedback/interaction/$interactionId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch feedback for interaction');
    }
  }

  /// Get feedback stats
  static Future<Map<String, dynamic>> getFeedbackStats() async {
    final response = await ApiClient.get('/ai-feedback/stats');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch feedback stats');
    }
  }
}
