// lib/models/bulk_notification.dart

class BulkNotification {
  final int? bulkNotificationId;
  final String title;
  final String message;
  final int createdByUserId;
  final DateTime? createdAt;
  final int sentCount;
  final bool isScheduled;
  final DateTime? scheduleTime;
  final bool isSent;
  final Map<String, dynamic>? targetCriteria;

  // Related user
  final Map<String, dynamic>? user;

  BulkNotification({
    this.bulkNotificationId,
    required this.title,
    required this.message,
    required this.createdByUserId,
    this.createdAt,
    this.sentCount = 0,
    this.isScheduled = false,
    this.scheduleTime,
    this.isSent = false,
    this.targetCriteria,
    this.user,
  });

  factory BulkNotification.fromJson(Map<String, dynamic> json) {
    return BulkNotification(
      bulkNotificationId: json['bulk_notification_id'],
      title: json['title'],
      message: json['message'],
      createdByUserId: json['created_by_user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      sentCount: json['sent_count'] ?? 0,
      isScheduled: json['is_scheduled'] ?? false,
      scheduleTime: json['schedule_time'] != null
          ? DateTime.parse(json['schedule_time'])
          : null,
      isSent: json['is_sent'] ?? false,
      targetCriteria: json['target_criteria'] != null
          ? Map<String, dynamic>.from(json['target_criteria'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bulkNotificationId != null)
        'bulk_notification_id': bulkNotificationId,
      'title': title,
      'message': message,
      'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'sent_count': sentCount,
      'is_scheduled': isScheduled,
      if (scheduleTime != null)
        'schedule_time': scheduleTime!.toIso8601String(),
      'is_sent': isSent,
      if (targetCriteria != null) 'target_criteria': targetCriteria,
      if (user != null) 'user': user,
    };
  }

  BulkNotification copyWith({
    int? bulkNotificationId,
    String? title,
    String? message,
    int? createdByUserId,
    DateTime? createdAt,
    int? sentCount,
    bool? isScheduled,
    DateTime? scheduleTime,
    bool? isSent,
    Map<String, dynamic>? targetCriteria,
    Map<String, dynamic>? user,
  }) {
    return BulkNotification(
      bulkNotificationId: bulkNotificationId ?? this.bulkNotificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      sentCount: sentCount ?? this.sentCount,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      isSent: isSent ?? this.isSent,
      targetCriteria: targetCriteria ?? this.targetCriteria,
      user: user ?? this.user,
    );
  }
}
