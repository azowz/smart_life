import '../api_client.dart';
import 'dart:convert';

class CategoryService {
  static Future<List<dynamic>> getCategories(
      {bool systemOnly = false, int? parentId}) async {
    String endpoint = '/categories/?system_only=$systemOnly';
    if (parentId != null) {
      endpoint += '&parent_id=$parentId';
    }
    final response = await ApiClient.get(endpoint);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  static Future<Map<String, dynamic>> getCategoryById(int categoryId) async {
    final response = await ApiClient.get('/categories/$categoryId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Category not found');
    }
  }

  static Future<Map<String, dynamic>> getCategoryTree(int categoryId) async {
    final response = await ApiClient.get('/categories/$categoryId/tree');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch category tree');
    }
  }

  static Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> categoryData) async {
    final response = await ApiClient.post('/categories/', categoryData);
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create category');
    }
  }

  static Future<Map<String, dynamic>> updateCategory(
      int categoryId, Map<String, dynamic> updates) async {
    final response = await ApiClient.put('/categories/$categoryId', updates);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update category');
    }
  }

  static Future<void> deleteCategory(int categoryId) async {
    final response = await ApiClient.delete('/categories/$categoryId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }
}
