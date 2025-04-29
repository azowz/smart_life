import '../api_client.dart';
import 'dart:convert';

class UserDefaultHabitService {
  /// Assign default habit to a user
  static Future<Map<String, dynamic>> assignHabit(
      Map<String, dynamic> habitData) async {
    final response = await ApiClient.post('/user-default-habits/', habitData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to assign default habit');
    }
  }

  /// Get all default habits for a user
  static Future<List<dynamic>> getUserHabits(int userId,
      {bool activeOnly = false}) async {
    final response = await ApiClient.get(
        '/user-default-habits/user/$userId?active_only=$activeOnly');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user habits');
    }
  }

  /// Update a user's assigned default habit
  static Future<Map<String, dynamic>> updateUserHabit(
      int userId, int habitId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put(
        '/user-default-habits/user/$userId/habit/$habitId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update user habit');
    }
  }

  /// Delete a user's assigned default habit
  static Future<void> deleteUserHabit(int userId, int habitId) async {
    final response = await ApiClient.delete(
        '/user-default-habits/user/$userId/habit/$habitId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user habit');
    }
  }
}
