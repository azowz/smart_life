// lib/models/ai_feedback.dart

class AIFeedback {
  final int? feedbackId;
  final int interactionId;
  final int userId;
  final int? rating;
  final String? feedbackText;
  final DateTime? createdAt;
  final bool isUsedForImprovement;

  // Relationships
  final Map<String, dynamic>? interaction;
  final Map<String, dynamic>? user;

  AIFeedback({
    this.feedbackId,
    required this.interactionId,
    required this.userId,
    this.rating,
    this.feedbackText,
    this.createdAt,
    this.isUsedForImprovement = false,
    this.interaction,
    this.user,
  });

  factory AIFeedback.fromJson(Map<String, dynamic> json) {
    return AIFeedback(
      feedbackId: json['feedback_id'],
      interactionId: json['interaction_id'],
      userId: json['user_id'],
      rating: json['rating'],
      feedbackText: json['feedback_text'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isUsedForImprovement: json['is_used_for_improvement'] ?? false,
      interaction: json['interaction'] != null
          ? Map<String, dynamic>.from(json['interaction'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (feedbackId != null) 'feedback_id': feedbackId,
      'interaction_id': interactionId,
      'user_id': userId,
      if (rating != null) 'rating': rating,
      if (feedbackText != null) 'feedback_text': feedbackText,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'is_used_for_improvement': isUsedForImprovement,
      if (interaction != null) 'interaction': interaction,
      if (user != null) 'user': user,
    };
  }

  AIFeedback copyWith({
    int? feedbackId,
    int? interactionId,
    int? userId,
    int? rating,
    String? feedbackText,
    DateTime? createdAt,
    bool? isUsedForImprovement,
    Map<String, dynamic>? interaction,
    Map<String, dynamic>? user,
  }) {
    return AIFeedback(
      feedbackId: feedbackId ?? this.feedbackId,
      interactionId: interactionId ?? this.interactionId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      feedbackText: feedbackText ?? this.feedbackText,
      createdAt: createdAt ?? this.createdAt,
      isUsedForImprovement: isUsedForImprovement ?? this.isUsedForImprovement,
      interaction: interaction ?? this.interaction,
      user: user ?? this.user,
    );
  }
}
