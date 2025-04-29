import '../api_client.dart';
import 'dart:convert';

class DefaultHabitService {
  /// Fetch all default habits
  static Future<List<dynamic>> getDefaultHabits({
    bool activeOnly = true,
    int? categoryId,
    bool? aiRecommended,
  }) async {
    String endpoint = '/default-habits?active_only=$activeOnly';
    if (categoryId != null) endpoint += '&category_id=$categoryId';
    if (aiRecommended != null) endpoint += '&ai_recommended=$aiRecommended';

    final response = await ApiClient.get(endpoint);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch default habits');
    }
  }

  /// Fetch single default habit by ID
  static Future<Map<String, dynamic>> getDefaultHabitById(
      int defaultHabitId) async {
    final response = await ApiClient.get('/default-habits/$defaultHabitId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Default habit not found');
    }
  }

  /// Create a new default habit
  static Future<Map<String, dynamic>> createDefaultHabit(
      Map<String, dynamic> habitData) async {
    final response = await ApiClient.post('/default-habits/', habitData);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create default habit: ${response.body}');
    }
  }

  /// Update an existing default habit
  static Future<Map<String, dynamic>> updateDefaultHabit(
      int habitId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put('/default-habits/$habitId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update default habit: ${response.body}');
    }
  }

  /// Delete a default habit
  static Future<void> deleteDefaultHabit(int habitId) async {
    final response = await ApiClient.delete('/default-habits/$habitId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete default habit: ${response.body}');
    }
  }

  /// Update adoption rate for a default habit
  static Future<double> updateAdoptionRate(int habitId) async {
    final response =
        await ApiClient.post('/default-habits/$habitId/adoption-rate', {});
    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to update adoption rate: ${response.body}');
    }
  }
}
