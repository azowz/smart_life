// lib/models/user.dart

class User {
  final int? userId;
  final String username;
  final String email;
  final String passwordHash;
  final String? phoneNumber;
  final String? profilePicture;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final bool isActive;
  final bool superuser;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  // Related entities (optional)
  final Map<String, dynamic>? settings;
  final List<Map<String, dynamic>>? tasks;
  final List<Map<String, dynamic>>? habits;
  final List<Map<String, dynamic>>? categoriesCreated;
  final List<Map<String, dynamic>>? activities;
  final List<Map<String, dynamic>>? aiInteractions;
  final List<Map<String, dynamic>>? notifications;
  final List<Map<String, dynamic>>? aiPromptTemplates;
  final List<Map<String, dynamic>>? systemSettings;
  final List<Map<String, dynamic>>? habitLogs;
  final List<Map<String, dynamic>>? userDefaultHabits;
  final List<Map<String, dynamic>>? aiTrainingTexts;
  final List<Map<String, dynamic>>? bulkNotifications;
  final List<Map<String, dynamic>>? configurations;
  final List<Map<String, dynamic>>? contents;

  User({
    this.userId,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.phoneNumber,
    this.profilePicture,
    this.firstName,
    this.lastName,
    this.gender,
    this.isActive = true,
    this.superuser = false,
    this.createdAt,
    this.lastLogin,
    this.settings,
    this.tasks,
    this.habits,
    this.categoriesCreated,
    this.activities,
    this.aiInteractions,
    this.notifications,
    this.aiPromptTemplates,
    this.systemSettings,
    this.habitLogs,
    this.userDefaultHabits,
    this.aiTrainingTexts,
    this.bulkNotifications,
    this.configurations,
    this.contents,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      passwordHash: json['password_hash'],
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      isActive: json['is_active'] ?? true,
      superuser: json['superuser'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      settings: json['settings'],
      tasks: (json['tasks'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      habits: (json['habits'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      categoriesCreated: (json['categories_created'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      activities: (json['activities'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      aiInteractions: (json['ai_interactions'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      notifications: (json['notifications'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      aiPromptTemplates: (json['ai_prompt_templates'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      systemSettings: (json['system_settings'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      habitLogs: (json['habit_logs'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      userDefaultHabits: (json['user_default_habits'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      aiTrainingTexts: (json['ai_training_texts'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      bulkNotifications: (json['bulk_notifications'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      configurations: (json['configurations'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      contents: (json['contents'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      'is_active': isActive,
      'superuser': superuser,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
      if (settings != null) 'settings': settings,
      if (tasks != null) 'tasks': tasks,
      if (habits != null) 'habits': habits,
      if (categoriesCreated != null) 'categories_created': categoriesCreated,
      if (activities != null) 'activities': activities,
      if (aiInteractions != null) 'ai_interactions': aiInteractions,
      if (notifications != null) 'notifications': notifications,
      if (aiPromptTemplates != null) 'ai_prompt_templates': aiPromptTemplates,
      if (systemSettings != null) 'system_settings': systemSettings,
      if (habitLogs != null) 'habit_logs': habitLogs,
      if (userDefaultHabits != null) 'user_default_habits': userDefaultHabits,
      if (aiTrainingTexts != null) 'ai_training_texts': aiTrainingTexts,
      if (bulkNotifications != null) 'bulk_notifications': bulkNotifications,
      if (configurations != null) 'configurations': configurations,
      if (contents != null) 'contents': contents,
    };
  }

  User copyWith({
    int? userId,
    String? username,
    String? email,
    String? passwordHash,
    String? phoneNumber,
    String? profilePicture,
    String? firstName,
    String? lastName,
    String? gender,
    bool? isActive,
    bool? superuser,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? settings,
    List<Map<String, dynamic>>? tasks,
    List<Map<String, dynamic>>? habits,
    List<Map<String, dynamic>>? categoriesCreated,
    List<Map<String, dynamic>>? activities,
    List<Map<String, dynamic>>? aiInteractions,
    List<Map<String, dynamic>>? notifications,
    List<Map<String, dynamic>>? aiPromptTemplates,
    List<Map<String, dynamic>>? systemSettings,
    List<Map<String, dynamic>>? habitLogs,
    List<Map<String, dynamic>>? userDefaultHabits,
    List<Map<String, dynamic>>? aiTrainingTexts,
    List<Map<String, dynamic>>? bulkNotifications,
    List<Map<String, dynamic>>? configurations,
    List<Map<String, dynamic>>? contents,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      superuser: superuser ?? this.superuser,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      settings: settings ?? this.settings,
      tasks: tasks ?? this.tasks,
      habits: habits ?? this.habits,
      categoriesCreated: categoriesCreated ?? this.categoriesCreated,
      activities: activities ?? this.activities,
      aiInteractions: aiInteractions ?? this.aiInteractions,
      notifications: notifications ?? this.notifications,
      aiPromptTemplates: aiPromptTemplates ?? this.aiPromptTemplates,
      systemSettings: systemSettings ?? this.systemSettings,
      habitLogs: habitLogs ?? this.habitLogs,
      userDefaultHabits: userDefaultHabits ?? this.userDefaultHabits,
      aiTrainingTexts: aiTrainingTexts ?? this.aiTrainingTexts,
      bulkNotifications: bulkNotifications ?? this.bulkNotifications,
      configurations: configurations ?? this.configurations,
      contents: contents ?? this.contents,
    );
  }
}
