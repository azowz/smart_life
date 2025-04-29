// lib/models/ai_prompt_template.dart

class AIPromptTemplate {
  final int? templateId;
  final String name;
  final String purpose;
  final String templateText;
  final Map<String, dynamic>? parameters;
  final int createdByUserId;
  final DateTime? createdAt;
  final DateTime? lastUpdated;
  final bool isActive;

  // Relationships
  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>>? interactions;

  AIPromptTemplate({
    this.templateId,
    required this.name,
    required this.purpose,
    required this.templateText,
    this.parameters,
    required this.createdByUserId,
    this.createdAt,
    this.lastUpdated,
    this.isActive = true,
    this.user,
    this.interactions,
  });

  factory AIPromptTemplate.fromJson(Map<String, dynamic> json) {
    return AIPromptTemplate(
      templateId: json['template_id'],
      name: json['name'],
      purpose: json['purpose'],
      templateText: json['template_text'],
      parameters: json['parameters'] != null
          ? Map<String, dynamic>.from(json['parameters'])
          : null,
      createdByUserId: json['created_by_user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
      isActive: json['is_active'] ?? true,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
      interactions: (json['interactions'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (templateId != null) 'template_id': templateId,
      'name': name,
      'purpose': purpose,
      'template_text': templateText,
      if (parameters != null) 'parameters': parameters,
      'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
      'is_active': isActive,
      if (user != null) 'user': user,
      if (interactions != null) 'interactions': interactions,
    };
  }

  AIPromptTemplate copyWith({
    int? templateId,
    String? name,
    String? purpose,
    String? templateText,
    Map<String, dynamic>? parameters,
    int? createdByUserId,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isActive,
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? interactions,
  }) {
    return AIPromptTemplate(
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      templateText: templateText ?? this.templateText,
      parameters: parameters ?? this.parameters,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      user: user ?? this.user,
      interactions: interactions ?? this.interactions,
    );
  }
}
