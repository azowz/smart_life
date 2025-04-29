// lib/models/task.dart

class Task {
  final int? taskId;
  final String title;
  final String? description;
  final int? createdByUserId;
  final DateTime? createdAt;
  final DateTime? lastUpdated;
  final bool isCompleted;

  // Related entities
  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>>? taskCategories;
  final List<Map<String, dynamic>>? categories;

  Task({
    this.taskId,
    required this.title,
    this.description,
    this.createdByUserId,
    this.createdAt,
    this.lastUpdated,
    this.isCompleted = false,
    this.user,
    this.taskCategories,
    this.categories,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'],
      title: json['title'],
      description: json['description'],
      createdByUserId: json['created_by_user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
      isCompleted: json['is_completed'] ?? false,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
      taskCategories: (json['task_categories'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      categories: (json['categories'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (taskId != null) 'task_id': taskId,
      'title': title,
      if (description != null) 'description': description,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
      'is_completed': isCompleted,
      if (user != null) 'user': user,
      if (taskCategories != null) 'task_categories': taskCategories,
      if (categories != null) 'categories': categories,
    };
  }

  Task copyWith({
    int? taskId,
    String? title,
    String? description,
    int? createdByUserId,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isCompleted,
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? taskCategories,
    List<Map<String, dynamic>>? categories,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCompleted: isCompleted ?? this.isCompleted,
      user: user ?? this.user,
      taskCategories: taskCategories ?? this.taskCategories,
      categories: categories ?? this.categories,
    );
  }
}
