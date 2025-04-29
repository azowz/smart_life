import '../api_client.dart';
import 'dart:convert';

class TaskCategoryService {
  /// Add a category to a task
  static Future<void> addCategoryToTask({
    required int taskId,
    required int categoryId,
  }) async {
    final response = await ApiClient.post(
      '/task-categories/tasks/$taskId/categories/$categoryId',
      {},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add category to task');
    }
  }

  /// Remove a category from a task
  static Future<void> removeCategoryFromTask({
    required int taskId,
    required int categoryId,
  }) async {
    final response = await ApiClient.delete(
      '/task-categories/tasks/$taskId/categories/$categoryId',
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove category from task');
    }
  }

  /// Get all categories linked to a task
  static Future<List<dynamic>> getCategoriesForTask(int taskId) async {
    final response =
        await ApiClient.get('/task-categories/tasks/$taskId/categories');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch categories for task');
    }
  }
}
