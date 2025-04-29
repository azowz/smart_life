// lib/models/system_statistics.dart

class SystemStatistics {
  final int? statId;
  final String statType;
  final double? aggregateValue;
  final int? userCount;
  final DateTime date;
  final Map<String, dynamic>? additionalData;
  final Map<String, dynamic>? aiUsageMetrics;
  final DateTime? createdAt;

  SystemStatistics({
    this.statId,
    required this.statType,
    this.aggregateValue,
    this.userCount,
    required this.date,
    this.additionalData,
    this.aiUsageMetrics,
    this.createdAt,
  });

  factory SystemStatistics.fromJson(Map<String, dynamic> json) {
    return SystemStatistics(
      statId: json['stat_id'],
      statType: json['stat_type'],
      aggregateValue: (json['aggregate_value'] != null)
          ? (json['aggregate_value'] as num).toDouble()
          : null,
      userCount: json['user_count'],
      date: DateTime.parse(json['date']),
      additionalData: json['additional_data'] != null
          ? Map<String, dynamic>.from(json['additional_data'])
          : null,
      aiUsageMetrics: json['ai_usage_metrics'] != null
          ? Map<String, dynamic>.from(json['ai_usage_metrics'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (statId != null) 'stat_id': statId,
      'stat_type': statType,
      if (aggregateValue != null) 'aggregate_value': aggregateValue,
      if (userCount != null) 'user_count': userCount,
      'date': date.toIso8601String(),
      if (additionalData != null) 'additional_data': additionalData,
      if (aiUsageMetrics != null) 'ai_usage_metrics': aiUsageMetrics,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  SystemStatistics copyWith({
    int? statId,
    String? statType,
    double? aggregateValue,
    int? userCount,
    DateTime? date,
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? aiUsageMetrics,
    DateTime? createdAt,
  }) {
    return SystemStatistics(
      statId: statId ?? this.statId,
      statType: statType ?? this.statType,
      aggregateValue: aggregateValue ?? this.aggregateValue,
      userCount: userCount ?? this.userCount,
      date: date ?? this.date,
      additionalData: additionalData ?? this.additionalData,
      aiUsageMetrics: aiUsageMetrics ?? this.aiUsageMetrics,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
