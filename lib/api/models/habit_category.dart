// lib/models/habit_category.dart

class HabitCategory {
  final int habitId;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related entities
  final Map<String, dynamic>? habit;
  final Map<String, dynamic>? category;

  HabitCategory({
    required this.habitId,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.habit,
    this.category,
  });

  factory HabitCategory.fromJson(Map<String, dynamic> json) {
    return HabitCategory(
      habitId: json['habit_id'],
      categoryId: json['category_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      habit: json['habit'] != null
          ? Map<String, dynamic>.from(json['habit'])
          : null,
      category: json['category'] != null
          ? Map<String, dynamic>.from(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (habit != null) 'habit': habit,
      if (category != null) 'category': category,
    };
  }

  HabitCategory copyWith({
    int? habitId,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? habit,
    Map<String, dynamic>? category,
  }) {
    return HabitCategory(
      habitId: habitId ?? this.habitId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      habit: habit ?? this.habit,
      category: category ?? this.category,
    );
  }
}
