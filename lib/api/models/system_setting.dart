// lib/models/system_setting.dart

class SystemSetting {
  final int? settingId;
  final String key;
  final Map<String, dynamic>? value;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? updatedByUserId;
  final Map<String, dynamic>? updatedByUser;

  SystemSetting({
    this.settingId,
    required this.key,
    this.value,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.updatedByUserId,
    this.updatedByUser,
  });

  factory SystemSetting.fromJson(Map<String, dynamic> json) {
    return SystemSetting(
      settingId: json['setting_id'],
      key: json['key'],
      value: json['value'] != null
          ? Map<String, dynamic>.from(json['value'])
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      updatedByUserId: json['updated_by_user_id'],
      updatedByUser: json['updated_by_user'] != null
          ? Map<String, dynamic>.from(json['updated_by_user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (settingId != null) 'setting_id': settingId,
      'key': key,
      'value': value,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (updatedByUserId != null) 'updated_by_user_id': updatedByUserId,
      if (updatedByUser != null) 'updated_by_user': updatedByUser,
    };
  }

  SystemSetting copyWith({
    int? settingId,
    String? key,
    Map<String, dynamic>? value,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? updatedByUserId,
    Map<String, dynamic>? updatedByUser,
  }) {
    return SystemSetting(
      settingId: settingId ?? this.settingId,
      key: key ?? this.key,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
      updatedByUser: updatedByUser ?? this.updatedByUser,
    );
  }
}
