// lib/models/default_habit.dart
class DefaultHabit {
  final int? defaultHabitId;
  final String name;
  final String? description;
  final int? categoryId;
  final int? createdBy;
  final bool isActive;
  final bool? isAiRecommended;
  final double? adoptionRate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DefaultHabit({
    this.defaultHabitId,
    required this.name,
    this.description,
    this.categoryId,
    this.createdBy,
    this.isActive = true,
    this.isAiRecommended,
    this.adoptionRate,
    this.createdAt,
    this.updatedAt,
  });

  factory DefaultHabit.fromJson(Map<String, dynamic> json) {
    return DefaultHabit(
      defaultHabitId: json['default_habit_id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category_id'],
      createdBy: json['created_by'],
      isActive: json['is_active'] ?? true,
      isAiRecommended: json['is_ai_recommended'],
      adoptionRate: json['adoption_rate'] != null
          ? double.parse(json['adoption_rate'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (defaultHabitId != null) 'default_habit_id': defaultHabitId,
      'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (createdBy != null) 'created_by': createdBy,
      'is_active': isActive,
      if (isAiRecommended != null) 'is_ai_recommended': isAiRecommended,
      if (adoptionRate != null) 'adoption_rate': adoptionRate,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy with updated properties
  DefaultHabit copyWith({
    int? defaultHabitId,
    String? name,
    String? description,
    int? categoryId,
    int? createdBy,
    bool? isActive,
    bool? isAiRecommended,
    double? adoptionRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DefaultHabit(
      defaultHabitId: defaultHabitId ?? this.defaultHabitId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      isAiRecommended: isAiRecommended ?? this.isAiRecommended,
      adoptionRate: adoptionRate ?? this.adoptionRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}