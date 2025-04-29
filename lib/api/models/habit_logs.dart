// lib/models/habit_log.dart

class HabitLog {
  final int? logId;
  final int habitId;
  final int? categoryId;
  final int userId;
  final DateTime? completedDate;
  final String? notes;
  final double? value;

  // Related entities
  final Map<String, dynamic>? habit;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? user;

  HabitLog({
    this.logId,
    required this.habitId,
    this.categoryId,
    required this.userId,
    this.completedDate,
    this.notes,
    this.value,
    this.habit,
    this.category,
    this.user,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      logId: json['log_id'],
      habitId: json['habit_id'],
      categoryId: json['category_id'],
      userId: json['user_id'],
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      notes: json['notes'],
      value: (json['value'] != null) ? (json['value'] as num).toDouble() : null,
      habit: json['habit'] != null
          ? Map<String, dynamic>.from(json['habit'])
          : null,
      category: json['category'] != null
          ? Map<String, dynamic>.from(json['category'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (logId != null) 'log_id': logId,
      'habit_id': habitId,
      if (categoryId != null) 'category_id': categoryId,
      'user_id': userId,
      if (completedDate != null)
        'completed_date': completedDate!.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (value != null) 'value': value,
      if (habit != null) 'habit': habit,
      if (category != null) 'category': category,
      if (user != null) 'user': user,
    };
  }

  HabitLog copyWith({
    int? logId,
    int? habitId,
    int? categoryId,
    int? userId,
    DateTime? completedDate,
    String? notes,
    double? value,
    Map<String, dynamic>? habit,
    Map<String, dynamic>? category,
    Map<String, dynamic>? user,
  }) {
    return HabitLog(
      logId: logId ?? this.logId,
      habitId: habitId ?? this.habitId,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      value: value ?? this.value,
      habit: habit ?? this.habit,
      category: category ?? this.category,
      user: user ?? this.user,
    );
  }
}
