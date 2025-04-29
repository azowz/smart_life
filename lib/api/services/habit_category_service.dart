import 'package:http/http.dart' as http;

import '../api_client.dart';
import 'dart:convert';

class HabitCategoryService {
  static Future<bool> addCategoryToHabit({
    required int habitId,
    required int categoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-api-url.com/addCategoryToHabit'), // Replace with your backend URL
        body: {
          'habitId': habitId.toString(),
          'categoryId': categoryId.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Assuming a success response from the backend
        return true;
      } else {
        // Handle failure (e.g., incorrect response, bad status code)
        return false;
      }
    } catch (e) {
      print('Error adding category to habit: $e');
      return false;
    }
  }

  static Future<void> removeCategoryFromHabit({
    required int habitId,
    required int categoryId,
  }) async {
    final response = await ApiClient.delete(
      '/habits/$habitId/categories/$categoryId',
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to remove category from habit');
    }
  }

  static Future<List<dynamic>> getCategoriesForHabit(int habitId) async {
    final response = await ApiClient.get('/habits/$habitId/categories');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch categories for habit');
    }
  }

  static Future<List<dynamic>> getHabitsByCategory(int categoryId) async {
    final response = await ApiClient.get('/categories/$categoryId/habits');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch habits by category');
    }
  }
}
