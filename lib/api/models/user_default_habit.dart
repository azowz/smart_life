// lib/models/user_default_habit.dart
class UserDefaultHabit {
  final int? id;
  final int userId;
  final int defaultHabitId;
  final bool isActive;
  final bool isCustomized;
  final String? customName;
  final String? customDescription;
  final DateTime? startDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields to store related entity data
  final Map<String, dynamic>? defaultHabit;
  final Map<String, dynamic>? user;

  UserDefaultHabit({
    this.id,
    required this.userId,
    required this.defaultHabitId,
    this.isActive = true,
    this.isCustomized = false,
    this.customName,
    this.customDescription,
    this.startDate,
    this.createdAt,
    this.updatedAt,
    this.defaultHabit,
    this.user,
  });

  factory UserDefaultHabit.fromJson(Map<String, dynamic> json) {
    return UserDefaultHabit(
      id: json['id'],
      userId: json['user_id'],
      defaultHabitId: json['default_habit_id'],
      isActive: json['is_active'] ?? true,
      isCustomized: json['is_customized'] ?? false,
      customName: json['custom_name'],
      customDescription: json['custom_description'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      defaultHabit: json['default_habit'] != null
          ? Map<String, dynamic>.from(json['default_habit'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'default_habit_id': defaultHabitId,
      'is_active': isActive,
      'is_customized': isCustomized,
      if (customName != null) 'custom_name': customName,
      if (customDescription != null) 'custom_description': customDescription,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Get the effective name of the habit (custom or default)
  String get name => isCustomized && customName != null
      ? customName!
      : defaultHabit != null
          ? defaultHabit!['name']
          : 'Unnamed Habit';

  // Get the effective description of the habit (custom or default)
  String? get description => isCustomized && customDescription != null
      ? customDescription
      : defaultHabit != null
          ? defaultHabit!['description']
          : null;

  // Create a copy with updated properties
  UserDefaultHabit copyWith({
    int? id,
    int? userId,
    int? defaultHabitId,
    bool? isActive,
    bool? isCustomized,
    String? customName,
    String? customDescription,
    DateTime? startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? defaultHabit,
    Map<String, dynamic>? user,
  }) {
    return UserDefaultHabit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      defaultHabitId: defaultHabitId ?? this.defaultHabitId,
      isActive: isActive ?? this.isActive,
      isCustomized: isCustomized ?? this.isCustomized,
      customName: customName ?? this.customName,
      customDescription: customDescription ?? this.customDescription,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      defaultHabit: defaultHabit ?? this.defaultHabit,
      user: user ?? this.user,
    );
  }
}
