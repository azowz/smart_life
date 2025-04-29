import '../api_client.dart';
import 'dart:convert';

class NotificationService {
  /// Create a new notification
  static Future<Map<String, dynamic>> createNotification(
      Map<String, dynamic> notificationData) async {
    final response = await ApiClient.post('/notification/', notificationData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create notification: ${response.body}');
    }
  }

  /// Get user notifications
  static Future<List<dynamic>> getUserNotifications(int userId,
      {bool unreadOnly = false}) async {
    String endpoint = '/notification/user/$userId';
    if (unreadOnly) {
      endpoint += '?unread_only=true';
    }
    final response = await ApiClient.get(endpoint);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user notifications');
    }
  }

  /// Mark a notification as read
  static Future<void> markNotificationAsRead(int notificationId,
      {int? userId}) async {
    String endpoint = '/notification/$notificationId/read';
    if (userId != null) {
      endpoint += '?user_id=$userId';
    }
    final response = await ApiClient.patch(endpoint, {});
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllNotificationsAsRead(int userId) async {
    final response =
        await ApiClient.patch('/notification/user/$userId/read-all', {});
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }

  /// Delete a notification
  static Future<void> deleteNotification(int notificationId,
      {int? userId}) async {
    String endpoint = '/notification/$notificationId';
    if (userId != null) {
      endpoint += '?user_id=$userId';
    }
    final response = await ApiClient.delete(endpoint);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete notification');
    }
  }
}
