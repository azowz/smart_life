// lib/models/task_category.dart

class TaskCategory {
  final int taskId;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related entities (optional)
  final Map<String, dynamic>? task;
  final Map<String, dynamic>? category;

  TaskCategory({
    required this.taskId,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.task,
    this.category,
  });

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      taskId: json['task_id'],
      categoryId: json['category_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      task:
          json['task'] != null ? Map<String, dynamic>.from(json['task']) : null,
      category: json['category'] != null
          ? Map<String, dynamic>.from(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (task != null) 'task': task,
      if (category != null) 'category': category,
    };
  }

  TaskCategory copyWith({
    int? taskId,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? task,
    Map<String, dynamic>? category,
  }) {
    return TaskCategory(
      taskId: taskId ?? this.taskId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      task: task ?? this.task,
      category: category ?? this.category,
    );
  }
}
