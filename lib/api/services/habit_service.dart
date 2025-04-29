import '../api_client.dart';
import 'dart:convert';

class HabitService {
  /// Fetch all habits
  static Future<List<dynamic>> getHabits() async {
    final response = await ApiClient.get('/habits/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch habits');
    }
  }

  /// Fetch habit by ID
  static Future<Map<String, dynamic>> getHabitById(int habitId) async {
    final response = await ApiClient.get('/habits/$habitId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Habit not found');
    }
  }

  /// Create a new habit
  static Future<Map<String, dynamic>> createHabit(
      Map<String, dynamic> habitData) async {
    final response = await ApiClient.post('/habits/', habitData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create habit');
    }
  }

  /// Update an existing habit
  static Future<Map<String, dynamic>> updateHabit(
      int habitId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put('/habits/$habitId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update habit');
    }
  }

  /// Delete a habit
  static Future<void> deleteHabit(int habitId) async {
    final response = await ApiClient.delete('/habits/$habitId');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete habit');
    }
  }

  /// Toggle habit active/inactive status
  static Future<Map<String, dynamic>> toggleHabitStatus(int habitId) async {
    final response = await ApiClient.patch('/habits/$habitId/toggle', {});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle habit status');
    }
  }

  /// Submit multiple habits for a user
  static Future<bool> submitHabitsForUser({
    required int userId,
    required List<String> habits,
  }) async {
    final response = await ApiClient.post(
      '/users/$userId/habits/',
      {'habits': habits},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to submit habits: ${response.body}');
    }
  }
}
