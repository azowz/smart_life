import '../api_client.dart';
import 'dart:convert';

class HabitLogService {
  static Future<List<dynamic>> getLogsForHabit(int habitId) async {
    final response = await ApiClient.get('/habit-logs/habit/$habitId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch habit logs');
    }
  }

  static Future<Map<String, dynamic>> createHabitLog(
      Map<String, dynamic> logData) async {
    final response = await ApiClient.post('/habit-logs/', logData);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create habit log');
    }
  }

  static Future<Map<String, dynamic>> updateHabitLog(
      int logId, Map<String, dynamic> updates) async {
    final response = await ApiClient.patch('/habit-logs/$logId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update habit log');
    }
  }

  static Future<void> deleteHabitLog(int logId) async {
    final response = await ApiClient.delete('/habit-logs/$logId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete habit log');
    }
  }

  static Future<int> getStreak(int habitId) async {
    final response = await ApiClient.get('/habit-logs/habit/$habitId/streak');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['streak'] ?? 0;
    } else {
      throw Exception('Failed to fetch habit streak');
    }
  }
}
