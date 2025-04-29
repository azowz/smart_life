// lib/models/ai_usage_log.dart

class AIUsageLog {
  final int? logId;
  final DateTime date;
  final int totalRequests;
  final int tokensConsumed;
  final double successRate;
  final int averageResponseTime;
  final double cost;
  final int errorCount;
  final Map<String, dynamic>? errorDetails;

  AIUsageLog({
    this.logId,
    required this.date,
    this.totalRequests = 0,
    this.tokensConsumed = 0,
    this.successRate = 0.00,
    this.averageResponseTime = 0,
    this.cost = 0.00,
    this.errorCount = 0,
    this.errorDetails,
  });

  factory AIUsageLog.fromJson(Map<String, dynamic> json) {
    return AIUsageLog(
      logId: json['log_id'],
      date: DateTime.parse(json['date']),
      totalRequests: json['total_requests'] ?? 0,
      tokensConsumed: json['tokens_consumed'] ?? 0,
      successRate: (json['success_rate'] != null)
          ? (json['success_rate'] as num).toDouble()
          : 0.00,
      averageResponseTime: json['average_response_time'] ?? 0,
      cost: (json['cost'] != null) ? (json['cost'] as num).toDouble() : 0.00,
      errorCount: json['error_count'] ?? 0,
      errorDetails: json['error_details'] != null
          ? Map<String, dynamic>.from(json['error_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (logId != null) 'log_id': logId,
      'date': date.toIso8601String(),
      'total_requests': totalRequests,
      'tokens_consumed': tokensConsumed,
      'success_rate': successRate,
      'average_response_time': averageResponseTime,
      'cost': cost,
      'error_count': errorCount,
      if (errorDetails != null) 'error_details': errorDetails,
    };
  }

  AIUsageLog copyWith({
    int? logId,
    DateTime? date,
    int? totalRequests,
    int? tokensConsumed,
    double? successRate,
    int? averageResponseTime,
    double? cost,
    int? errorCount,
    Map<String, dynamic>? errorDetails,
  }) {
    return AIUsageLog(
      logId: logId ?? this.logId,
      date: date ?? this.date,
      totalRequests: totalRequests ?? this.totalRequests,
      tokensConsumed: tokensConsumed ?? this.tokensConsumed,
      successRate: successRate ?? this.successRate,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      cost: cost ?? this.cost,
      errorCount: errorCount ?? this.errorCount,
      errorDetails: errorDetails ?? this.errorDetails,
    );
  }
}
