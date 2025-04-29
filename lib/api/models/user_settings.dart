// lib/models/user_settings.dart

class UserSettings {
  final int? settingsId;
  final int userId;
  final String theme;
  final Map<String, dynamic> notificationPreferences;
  final String language;
  final String timeZone;
  final bool aiAssistantEnabled;
  final String timezone; // Redundant field as in the DB
  final Map<String, dynamic>? user; // Related user data if needed

  UserSettings({
    this.settingsId,
    required this.userId,
    this.theme = "system",
    this.notificationPreferences = const {},
    this.language = "en",
    this.timeZone = "UTC",
    this.aiAssistantEnabled = true,
    this.timezone = "UTC",
    this.user,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      settingsId: json['settings_id'],
      userId: json['user_id'],
      theme: json['theme'] ?? "system",
      notificationPreferences: json['notification_preferences'] != null
          ? Map<String, dynamic>.from(json['notification_preferences'])
          : {},
      language: json['language'] ?? "en",
      timeZone: json['time_zone'] ?? "UTC",
      aiAssistantEnabled: json['ai_assistant_enabled'] ?? true,
      timezone: json['timezone'] ?? "UTC",
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (settingsId != null) 'settings_id': settingsId,
      'user_id': userId,
      'theme': theme,
      'notification_preferences': notificationPreferences,
      'language': language,
      'time_zone': timeZone,
      'ai_assistant_enabled': aiAssistantEnabled,
      'timezone': timezone,
      if (user != null) 'user': user,
    };
  }

  UserSettings copyWith({
    int? settingsId,
    int? userId,
    String? theme,
    Map<String, dynamic>? notificationPreferences,
    String? language,
    String? timeZone,
    bool? aiAssistantEnabled,
    String? timezone,
    Map<String, dynamic>? user,
  }) {
    return UserSettings(
      settingsId: settingsId ?? this.settingsId,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      language: language ?? this.language,
      timeZone: timeZone ?? this.timeZone,
      aiAssistantEnabled: aiAssistantEnabled ?? this.aiAssistantEnabled,
      timezone: timezone ?? this.timezone,
      user: user ?? this.user,
    );
  }
}
