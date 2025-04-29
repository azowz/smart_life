// lib/models/category.dart

class Category {
  final int? categoryId;
  final String name;
  final String? description;
  final String? color;
  final String? colorName;
  final String? icon;
  final String? location;
  final String? repeat;
  final String? station;
  final DateTime? remainder;
  final Duration? progressTime;
  final double? progressLength;
  final double? progressWeight;
  final bool isSystem;
  final bool aiRecommended;
  final int? createdByUserId;
  final int? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relationships
  final Map<String, dynamic>? creatorUser;
  final Map<String, dynamic>? parent;
  final List<Map<String, dynamic>>? subcategories;
  final List<Map<String, dynamic>>? habitCategories;
  final List<Map<String, dynamic>>? habitLogs;
  final List<Map<String, dynamic>>? taskCategories;
  final List<Map<String, dynamic>>? tasks;
  final List<Map<String, dynamic>>? trainingTexts;
  final List<Map<String, dynamic>>? defaultHabits;

  Category({
    this.categoryId,
    required this.name,
    this.description,
    this.color,
    this.colorName,
    this.icon,
    this.location,
    this.repeat,
    this.station,
    this.remainder,
    this.progressTime,
    this.progressLength,
    this.progressWeight,
    this.isSystem = false,
    this.aiRecommended = false,
    this.createdByUserId,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.creatorUser,
    this.parent,
    this.subcategories,
    this.habitCategories,
    this.habitLogs,
    this.taskCategories,
    this.tasks,
    this.trainingTexts,
    this.defaultHabits,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      colorName: json['color_name'],
      icon: json['icon'],
      location: json['location'],
      repeat: json['repeat'],
      station: json['station'],
      remainder:
          json['remainder'] != null ? DateTime.parse(json['remainder']) : null,
      progressTime: json['progress_time'] != null
          ? Duration(
              seconds: json[
                  'progress_time']) // must be sent/handled as seconds in API
          : null,
      progressLength: (json['progress_length'] != null)
          ? (json['progress_length'] as num).toDouble()
          : null,
      progressWeight: (json['progress_weight'] != null)
          ? (json['progress_weight'] as num).toDouble()
          : null,
      isSystem: json['is_system'] ?? false,
      aiRecommended: json['ai_recommended'] ?? false,
      createdByUserId: json['created_by_user_id'],
      parentId: json['parent_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      creatorUser: json['creator_user'] != null
          ? Map<String, dynamic>.from(json['creator_user'])
          : null,
      parent: json['parent'] != null
          ? Map<String, dynamic>.from(json['parent'])
          : null,
      subcategories: (json['subcategories'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      habitCategories: (json['habit_categories'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      habitLogs: (json['habit_logs'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      taskCategories: (json['task_categories'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      tasks: (json['tasks'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      trainingTexts: (json['training_texts'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      defaultHabits: (json['default_habits'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (colorName != null) 'color_name': colorName,
      if (icon != null) 'icon': icon,
      if (location != null) 'location': location,
      if (repeat != null) 'repeat': repeat,
      if (station != null) 'station': station,
      if (remainder != null) 'remainder': remainder!.toIso8601String(),
      if (progressTime != null) 'progress_time': progressTime!.inSeconds,
      if (progressLength != null) 'progress_length': progressLength,
      if (progressWeight != null) 'progress_weight': progressWeight,
      'is_system': isSystem,
      'ai_recommended': aiRecommended,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (creatorUser != null) 'creator_user': creatorUser,
      if (parent != null) 'parent': parent,
      if (subcategories != null) 'subcategories': subcategories,
      if (habitCategories != null) 'habit_categories': habitCategories,
      if (habitLogs != null) 'habit_logs': habitLogs,
      if (taskCategories != null) 'task_categories': taskCategories,
      if (tasks != null) 'tasks': tasks,
      if (trainingTexts != null) 'training_texts': trainingTexts,
      if (defaultHabits != null) 'default_habits': defaultHabits,
    };
  }

  Category copyWith({
    int? categoryId,
    String? name,
    String? description,
    String? color,
    String? colorName,
    String? icon,
    String? location,
    String? repeat,
    String? station,
    DateTime? remainder,
    Duration? progressTime,
    double? progressLength,
    double? progressWeight,
    bool? isSystem,
    bool? aiRecommended,
    int? createdByUserId,
    int? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? creatorUser,
    Map<String, dynamic>? parent,
    List<Map<String, dynamic>>? subcategories,
    List<Map<String, dynamic>>? habitCategories,
    List<Map<String, dynamic>>? habitLogs,
    List<Map<String, dynamic>>? taskCategories,
    List<Map<String, dynamic>>? tasks,
    List<Map<String, dynamic>>? trainingTexts,
    List<Map<String, dynamic>>? defaultHabits,
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      colorName: colorName ?? this.colorName,
      icon: icon ?? this.icon,
      location: location ?? this.location,
      repeat: repeat ?? this.repeat,
      station: station ?? this.station,
      remainder: remainder ?? this.remainder,
      progressTime: progressTime ?? this.progressTime,
      progressLength: progressLength ?? this.progressLength,
      progressWeight: progressWeight ?? this.progressWeight,
      isSystem: isSystem ?? this.isSystem,
      aiRecommended: aiRecommended ?? this.aiRecommended,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorUser: creatorUser ?? this.creatorUser,
      parent: parent ?? this.parent,
      subcategories: subcategories ?? this.subcategories,
      habitCategories: habitCategories ?? this.habitCategories,
      habitLogs: habitLogs ?? this.habitLogs,
      taskCategories: taskCategories ?? this.taskCategories,
      tasks: tasks ?? this.tasks,
      trainingTexts: trainingTexts ?? this.trainingTexts,
      defaultHabits: defaultHabits ?? this.defaultHabits,
    );
  }
}
