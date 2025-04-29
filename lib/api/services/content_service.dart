import '../api_client.dart';
import 'dart:convert';

class ContentService {
  /// Fetch all content items
  static Future<List<dynamic>> getAllContent() async {
    final response = await ApiClient.get('/content/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch content');
    }
  }

  /// Fetch a single content item by ID or slug
  static Future<Map<String, dynamic>> getContent(String idOrSlug) async {
    final response = await ApiClient.get('/content/$idOrSlug/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Content not found');
    }
  }

  /// Create new content
  static Future<Map<String, dynamic>> createContent(
      Map<String, dynamic> contentData) async {
    final response = await ApiClient.post('/content/', contentData);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create content: ${response.body}');
    }
  }

  /// Update existing content
  static Future<Map<String, dynamic>> updateContent(
      int contentId, Map<String, dynamic> updates) async {
    final response = await ApiClient.patch('/content/$contentId/', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update content: ${response.body}');
    }
  }

  /// Delete content
  static Future<bool> deleteContent(int contentId) async {
    final response = await ApiClient.delete('/content/$contentId/');
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete content: ${response.body}');
    }
  }
}
