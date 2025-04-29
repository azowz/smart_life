import '../api_client.dart';
import 'dart:convert';

class UserStatisticsService {
  /// Update user statistics
  static Future<Map<String, dynamic>> updateStatistics(
      Map<String, dynamic> statsData) async {
    final response = await ApiClient.post('/user-statistics/update', statsData);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update user statistics');
    }
  }

  /// Get statistics for a user
  static Future<Map<String, dynamic>> getStatistics(
      int userId, String date) async {
    final response =
        await ApiClient.get('/user-statistics/user/$userId?date=$date');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user statistics');
    }
  }
}
