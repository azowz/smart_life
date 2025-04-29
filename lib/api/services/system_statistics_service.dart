import '../api_client.dart';
import 'dart:convert';

class SystemStatisticsService {
  /// Get all system statistics
  static Future<List<dynamic>> getSystemStatistics(
      {String? statType, String? startDate, String? endDate}) async {
    String endpoint = '/system-statistics/';
    List<String> params = [];
    if (statType != null) params.add('stat_type=$statType');
    if (startDate != null) params.add('start_date=$startDate');
    if (endDate != null) params.add('end_date=$endDate');
    if (params.isNotEmpty) endpoint += '?' + params.join('&');

    final response = await ApiClient.get(endpoint);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch system statistics');
    }
  }

  /// Get latest statistic by type
  static Future<Map<String, dynamic>> getLatestStatistic(
      String statType) async {
    final response = await ApiClient.get('/system-statistics/latest/$statType');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch latest statistic');
    }
  }

  /// Calculate user growth statistics
  static Future<Map<String, dynamic>> calculateUserGrowth() async {
    final response =
        await ApiClient.post('/system-statistics/calculate/user-growth', {});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to calculate user growth');
    }
  }

  /// Calculate AI usage statistics
  static Future<Map<String, dynamic>> calculateAIUsage() async {
    final response =
        await ApiClient.post('/system-statistics/calculate/ai-usage', {});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to calculate AI usage');
    }
  }
}
