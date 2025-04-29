// lib/models/habit.dart

class Habit {
  final int? habitId;
  final int userId;
  final String name;
  final String? color;
  final String? colorName;
  final String? description;
  final String frequency;
  final List<dynamic>? reminders;
  final String? time; // Time is stored as String in ISO format like 'HH:mm:ss'
  final DateTime? startDate;
  final int targetCount;
  final bool isDefaultHabit;
  final int? defaultHabitId;
  final bool aiGenerated;
  final DateTime? createdAt;

  // Related entities
  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>>? derivedHabits;
  final List<Map<String, dynamic>>? logs;
  final List<Map<String, dynamic>>? habitCategories;

  Habit({
    this.habitId,
    required this.userId,
    required this.name,
    this.color = "#4287f5",
    this.colorName,
    this.description,
    this.frequency = "daily",
    this.reminders = const [],
    this.time,
    this.startDate,
    this.targetCount = 1,
    this.isDefaultHabit = false,
    this.defaultHabitId,
    this.aiGenerated = false,
    this.createdAt,
    this.user,
    this.derivedHabits,
    this.logs,
    this.habitCategories,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      habitId: json['habit_id'],
      userId: json['user_id'],
      name: json['name'],
      color: json['color'] ?? "#4287f5",
      colorName: json['color_name'],
      description: json['description'],
      frequency: json['frequency'] ?? "daily",
      reminders: json['reminders'] != null
          ? List<dynamic>.from(json['reminders'])
          : [],
      time: json['time'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      targetCount: json['target_count'] ?? 1,
      isDefaultHabit: json['is_default_habit'] ?? false,
      defaultHabitId: json['default_habit_id'],
      aiGenerated: json['ai_generated'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
      derivedHabits: (json['derived_habits'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      logs: (json['logs'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      habitCategories: (json['habit_categories'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (habitId != null) 'habit_id': habitId,
      'user_id': userId,
      'name': name,
      'color': color,
      if (colorName != null) 'color_name': colorName,
      if (description != null) 'description': description,
      'frequency': frequency,
      'reminders': reminders,
      if (time != null) 'time': time,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      'target_count': targetCount,
      'is_default_habit': isDefaultHabit,
      if (defaultHabitId != null) 'default_habit_id': defaultHabitId,
      'ai_generated': aiGenerated,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (user != null) 'user': user,
      if (derivedHabits != null) 'derived_habits': derivedHabits,
      if (logs != null) 'logs': logs,
      if (habitCategories != null) 'habit_categories': habitCategories,
    };
  }

  Habit copyWith({
    int? habitId,
    int? userId,
    String? name,
    String? color,
    String? colorName,
    String? description,
    String? frequency,
    List<dynamic>? reminders,
    String? time,
    DateTime? startDate,
    int? targetCount,
    bool? isDefaultHabit,
    int? defaultHabitId,
    bool? aiGenerated,
    DateTime? createdAt,
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? derivedHabits,
    List<Map<String, dynamic>>? logs,
    List<Map<String, dynamic>>? habitCategories,
  }) {
    return Habit(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      colorName: colorName ?? this.colorName,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminders: reminders ?? this.reminders,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      targetCount: targetCount ?? this.targetCount,
      isDefaultHabit: isDefaultHabit ?? this.isDefaultHabit,
      defaultHabitId: defaultHabitId ?? this.defaultHabitId,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      derivedHabits: derivedHabits ?? this.derivedHabits,
      logs: logs ?? this.logs,
      habitCategories: habitCategories ?? this.habitCategories,
    );
  }
}
