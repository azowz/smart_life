// lib/models/notification.dart

class NotificationModel {
  final int? notificationId;
  final int userId;
  final String title;
  final String message;
  final bool isRead;
  final String notificationType;
  final bool aiGenerated;
  final DateTime? createdAt;
  final Map<String, dynamic>? user;

  NotificationModel({
    this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.notificationType,
    this.aiGenerated = false,
    this.createdAt,
    this.user,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      notificationType: json['notification_type'],
      aiGenerated: json['ai_generated'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (notificationId != null) 'notification_id': notificationId,
      'user_id': userId,
      'title': title,
      'message': message,
      'is_read': isRead,
      'notification_type': notificationType,
      'ai_generated': aiGenerated,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (user != null) 'user': user,
    };
  }

  NotificationModel copyWith({
    int? notificationId,
    int? userId,
    String? title,
    String? message,
    bool? isRead,
    String? notificationType,
    bool? aiGenerated,
    DateTime? createdAt,
    Map<String, dynamic>? user,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType ?? this.notificationType,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }
}
