// lib/models/ai_interaction.dart

class AIInteraction {
  final int? interactionId;
  final int userId;
  final String prompt;
  final String? response;
  final int? templateId;
  final String? interactionType;
  final DateTime? createdAt;
  final int? processingTime;
  final int? tokensUsed;
  final bool wasSuccessful;

  // Relationships
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? template;

  AIInteraction({
    this.interactionId,
    required this.userId,
    required this.prompt,
    this.response,
    this.templateId,
    this.interactionType,
    this.createdAt,
    this.processingTime,
    this.tokensUsed,
    this.wasSuccessful = true,
    this.user,
    this.template,
  });

  factory AIInteraction.fromJson(Map<String, dynamic> json) {
    return AIInteraction(
      interactionId: json['interaction_id'],
      userId: json['user_id'],
      prompt: json['prompt'],
      response: json['response'],
      templateId: json['template_id'],
      interactionType: json['interaction_type'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      processingTime: json['processing_time'],
      tokensUsed: json['tokens_used'],
      wasSuccessful: json['was_successful'] ?? true,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
      template: json['template'] != null
          ? Map<String, dynamic>.from(json['template'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (interactionId != null) 'interaction_id': interactionId,
      'user_id': userId,
      'prompt': prompt,
      if (response != null) 'response': response,
      if (templateId != null) 'template_id': templateId,
      if (interactionType != null) 'interaction_type': interactionType,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (processingTime != null) 'processing_time': processingTime,
      if (tokensUsed != null) 'tokens_used': tokensUsed,
      'was_successful': wasSuccessful,
      if (user != null) 'user': user,
      if (template != null) 'template': template,
    };
  }

  AIInteraction copyWith({
    int? interactionId,
    int? userId,
    String? prompt,
    String? response,
    int? templateId,
    String? interactionType,
    DateTime? createdAt,
    int? processingTime,
    int? tokensUsed,
    bool? wasSuccessful,
    Map<String, dynamic>? user,
    Map<String, dynamic>? template,
  }) {
    return AIInteraction(
      interactionId: interactionId ?? this.interactionId,
      userId: userId ?? this.userId,
      prompt: prompt ?? this.prompt,
      response: response ?? this.response,
      templateId: templateId ?? this.templateId,
      interactionType: interactionType ?? this.interactionType,
      createdAt: createdAt ?? this.createdAt,
      processingTime: processingTime ?? this.processingTime,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      user: user ?? this.user,
      template: template ?? this.template,
    );
  }
}
