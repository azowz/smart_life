import '../api_client.dart';
import 'dart:convert';

class TaskService {
  /// Fetch all tasks for current user
  static Future<List<dynamic>> getTasks() async {
    final response = await ApiClient.get('/tasks/');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  /// Get task by ID
  static Future<Map<String, dynamic>> getTaskById(int taskId) async {
    final response = await ApiClient.get('/tasks/$taskId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Task not found');
    }
  }

  /// Create a new task
  static Future<Map<String, dynamic>> createTask(
      Map<String, dynamic> taskData) async {
    final response = await ApiClient.post('/tasks/', taskData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  /// Update an existing task
  static Future<Map<String, dynamic>> updateTask(
      int taskId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put('/tasks/$taskId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  /// Delete a task
  static Future<void> deleteTask(int taskId) async {
    final response = await ApiClient.delete('/tasks/$taskId');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  /// Toggle task completion
  static Future<Map<String, dynamic>> toggleTaskStatus(int taskId) async {
    final response = await ApiClient.patch('/tasks/$taskId/toggle', {});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle task status');
    }
  }
}
