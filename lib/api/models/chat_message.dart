// lib/models/chat_message.dart

class ChatMessage {
  final int? messageId;
  final int userId;
  final String content;
  final bool isAiResponse;
  final DateTime? createdAt;
  final int? relatedEntityId;
  final String? relatedEntityType;

  // Related user (optional)
  final Map<String, dynamic>? user;

  ChatMessage({
    this.messageId,
    required this.userId,
    required this.content,
    this.isAiResponse = false,
    this.createdAt,
    this.relatedEntityId,
    this.relatedEntityType,
    this.user,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['message_id'],
      userId: json['user_id'],
      content: json['content'],
      isAiResponse: json['is_ai_response'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      relatedEntityId: json['related_entity_id'],
      relatedEntityType: json['related_entity_type'],
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (messageId != null) 'message_id': messageId,
      'user_id': userId,
      'content': content,
      'is_ai_response': isAiResponse,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (relatedEntityId != null) 'related_entity_id': relatedEntityId,
      if (relatedEntityType != null) 'related_entity_type': relatedEntityType,
      if (user != null) 'user': user,
    };
  }

  ChatMessage copyWith({
    int? messageId,
    int? userId,
    String? content,
    bool? isAiResponse,
    DateTime? createdAt,
    int? relatedEntityId,
    String? relatedEntityType,
    Map<String, dynamic>? user,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isAiResponse: isAiResponse ?? this.isAiResponse,
      createdAt: createdAt ?? this.createdAt,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      user: user ?? this.user,
    );
  }
}
