// lib/repositories/habit_repository.dart
import 'dart:async';
import 'package:final_project/api/api_client.dart';

import '../api/models/default_habit.dart';
import 'dart:convert';

class HabitRepository {
  // Singleton pattern
  static final HabitRepository _instance = HabitRepository._internal();

  factory HabitRepository() {
    return _instance;
  }

  HabitRepository._internal();

  // Cache for default habits
  List<DefaultHabit>? _defaultHabitsCache;

  // Get all default habits with optional filters
  Future<List<DefaultHabit>> getDefaultHabits({
    bool activeOnly = true,
    int? categoryId,
    bool? aiRecommended,
  }) async {
    try {
      // Create query parameters
      String queryParams = '?active_only=$activeOnly';
      if (categoryId != null) {
        queryParams += '&category_id=$categoryId';
      }
      if (aiRecommended != null) {
        queryParams += '&ai_recommended=$aiRecommended';
      }

      // Make API request
      final response = await ApiClient.get('/default-habits$queryParams');

      if (response.statusCode == 200) {
        final List<dynamic> habitsJson = json.decode(response.body);
        final List<DefaultHabit> habits =
            habitsJson.map((json) => DefaultHabit.fromJson(json)).toList();

        // Update cache
        _defaultHabitsCache = habits;

        return habits;
      } else {
        throw Exception(
            'Failed to load default habits: ${response.statusCode}');
      }
    } catch (e) {
      // Return cache if available and there's an error
      if (_defaultHabitsCache != null) {
        return _defaultHabitsCache!;
      }

      print('Error getting default habits: $e');
      // Return empty list instead of throwing to provide graceful fallback
      return [];
    }
  }

  // Assign multiple habits to a user by habit names
  Future<bool> bulkAssignHabitsByName({
    required String userId, // Changed from username to userId
    required List<String> habitNames,
  }) async {
    try {
      final response = await ApiClient.post(
        '/habits/bulk_add/',
        {
          'user_id': userId, // Changed from 'username' to 'user_id'
          'habits': habitNames,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error bulk assigning habits: $e');
      return false;
    }
  }

  // Get a specific default habit by ID
  Future<DefaultHabit?> getDefaultHabit(int habitId) async {
    try {
      final response = await ApiClient.get('/default-habits/$habitId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> habitJson = json.decode(response.body);
        return DefaultHabit.fromJson(habitJson);
      } else {
        throw Exception('Failed to load habit: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting default habit: $e');
      return null;
    }
  }

  // Add a user's specific habit
  Future<bool> assignHabitToUser({
    required String userId,
    required int defaultHabitId,
    bool isActive = true,
  }) async {
    try {
      final response = await ApiClient.post(
        '/user-default-habits/',
        {
          'user_id': userId,
          'default_habit_id': defaultHabitId,
          'is_active': isActive,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error assigning habit to user: $e');
      return false;
    }
  }

  // Get all habits assigned to a user
  Future<List<Map<String, dynamic>>> getUserHabits(String userId,
      {bool activeOnly = true}) async {
    try {
      final response = await ApiClient.get(
        '/user-default-habits/user/$userId?active_only=$activeOnly',
      );

      if (response.statusCode == 200) {
        final List<dynamic> habitsJson = json.decode(response.body);
        return habitsJson.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load user habits: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user habits: $e');
      return [];
    }
  }

  // Clear cache
  void clearCache() {
    _defaultHabitsCache = null;
  }
}
