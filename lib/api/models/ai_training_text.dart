// lib/models/ai_training_text.dart

class AITrainingText {
  final int? textId;
  final String content;
  final String contentType;
  final int? categoryId;
  final String? description;
  final int? createdByUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int usageCount;
  final double? effectivenessRating;
  final bool isActive;

  // Relationships
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? category;

  AITrainingText({
    this.textId,
    required this.content,
    required this.contentType,
    this.categoryId,
    this.description,
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
    this.usageCount = 0,
    this.effectivenessRating,
    this.isActive = true,
    this.user,
    this.category,
  });

  factory AITrainingText.fromJson(Map<String, dynamic> json) {
    return AITrainingText(
      textId: json['text_id'],
      content: json['content'],
      contentType: json['content_type'],
      categoryId: json['category_id'],
      description: json['description'],
      createdByUserId: json['created_by_user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      usageCount: json['usage_count'] ?? 0,
      effectivenessRating: json['effectiveness_rating'] != null
          ? (json['effectiveness_rating'] as num).toDouble()
          : null,
      isActive: json['is_active'] ?? true,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
      category: json['category'] != null
          ? Map<String, dynamic>.from(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (textId != null) 'text_id': textId,
      'content': content,
      'content_type': contentType,
      if (categoryId != null) 'category_id': categoryId,
      if (description != null) 'description': description,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'usage_count': usageCount,
      if (effectivenessRating != null)
        'effectiveness_rating': effectivenessRating,
      'is_active': isActive,
      if (user != null) 'user': user,
      if (category != null) 'category': category,
    };
  }

  AITrainingText copyWith({
    int? textId,
    String? content,
    String? contentType,
    int? categoryId,
    String? description,
    int? createdByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
    double? effectivenessRating,
    bool? isActive,
    Map<String, dynamic>? user,
    Map<String, dynamic>? category,
  }) {
    return AITrainingText(
      textId: textId ?? this.textId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
      effectivenessRating: effectivenessRating ?? this.effectivenessRating,
      isActive: isActive ?? this.isActive,
      user: user ?? this.user,
      category: category ?? this.category,
    );
  }
}
