// lib/models/configuration.dart

class Configuration {
  final int? configId;
  final String apiKey;
  final String modelVersion;
  final String endpointUrl;
  final int requestTimeout;
  final int maxTokens;
  final double temperature;
  final bool isActive;
  final int? updatedByUserId;
  final DateTime? updatedAt;

  // Related user
  final Map<String, dynamic>? user;

  Configuration({
    this.configId,
    required this.apiKey,
    required this.modelVersion,
    required this.endpointUrl,
    this.requestTimeout = 30,
    this.maxTokens = 2048,
    this.temperature = 0.7,
    this.isActive = false,
    this.updatedByUserId,
    this.updatedAt,
    this.user,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      configId: json['config_id'],
      apiKey: json['api_key'],
      modelVersion: json['model_version'],
      endpointUrl: json['endpoint_url'],
      requestTimeout: json['request_timeout'] ?? 30,
      maxTokens: json['max_tokens'] ?? 2048,
      temperature: (json['temperature'] != null)
          ? (json['temperature'] as num).toDouble()
          : 0.7,
      isActive: json['is_active'] ?? false,
      updatedByUserId: json['updated_by_user_id'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (configId != null) 'config_id': configId,
      'api_key': apiKey,
      'model_version': modelVersion,
      'endpoint_url': endpointUrl,
      'request_timeout': requestTimeout,
      'max_tokens': maxTokens,
      'temperature': temperature,
      'is_active': isActive,
      if (updatedByUserId != null) 'updated_by_user_id': updatedByUserId,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (user != null) 'user': user,
    };
  }

  Configuration copyWith({
    int? configId,
    String? apiKey,
    String? modelVersion,
    String? endpointUrl,
    int? requestTimeout,
    int? maxTokens,
    double? temperature,
    bool? isActive,
    int? updatedByUserId,
    DateTime? updatedAt,
    Map<String, dynamic>? user,
  }) {
    return Configuration(
      configId: configId ?? this.configId,
      apiKey: apiKey ?? this.apiKey,
      modelVersion: modelVersion ?? this.modelVersion,
      endpointUrl: endpointUrl ?? this.endpointUrl,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      isActive: isActive ?? this.isActive,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
