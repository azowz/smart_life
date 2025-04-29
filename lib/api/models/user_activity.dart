// lib/models/user_activity.dart

class UserActivity {
  final int? activityId;
  final int userId;
  final String activityType;
  final int? entityId;
  final String? entityType;
  final bool aiInteraction;
  final DateTime? createdAt;
  final Map<String, dynamic>? deviceInfo;
  final Map<String, dynamic>? user; // Related user data if needed

  UserActivity({
    this.activityId,
    required this.userId,
    required this.activityType,
    this.entityId,
    this.entityType,
    this.aiInteraction = false,
    this.createdAt,
    this.deviceInfo,
    this.user,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      activityId: json['activity_id'],
      userId: json['user_id'],
      activityType: json['activity_type'],
      entityId: json['entity_id'],
      entityType: json['entity_type'],
      aiInteraction: json['ai_interaction'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      deviceInfo: json['device_info'] != null
          ? Map<String, dynamic>.from(json['device_info'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (activityId != null) 'activity_id': activityId,
      'user_id': userId,
      'activity_type': activityType,
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      'ai_interaction': aiInteraction,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (user != null) 'user': user,
    };
  }

  UserActivity copyWith({
    int? activityId,
    int? userId,
    String? activityType,
    int? entityId,
    String? entityType,
    bool? aiInteraction,
    DateTime? createdAt,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? user,
  }) {
    return UserActivity(
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      aiInteraction: aiInteraction ?? this.aiInteraction,
      createdAt: createdAt ?? this.createdAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      user: user ?? this.user,
    );
  }
}
