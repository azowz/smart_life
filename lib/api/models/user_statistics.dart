// lib/models/user_statistics.dart

class UserStatistics {
  final int? statId;
  final int userId;
  final int tasksCompleted;
  final int tasksPending;
  final int habitsStreak;
  final double habitsCompletionRate;
  final int productivityScore;
  final double loginFrequency;
  final DateTime? lastActiveDate;
  final int aiInteractionCount;
  final double aiSuggestionAdoptionRate;
  final DateTime date;

  // Relationship (optional, if you want user info included)
  final Map<String, dynamic>? user;

  UserStatistics({
    this.statId,
    required this.userId,
    this.tasksCompleted = 0,
    this.tasksPending = 0,
    this.habitsStreak = 0,
    this.habitsCompletionRate = 0.00,
    this.productivityScore = 0,
    this.loginFrequency = 0.00,
    this.lastActiveDate,
    this.aiInteractionCount = 0,
    this.aiSuggestionAdoptionRate = 0.00,
    required this.date,
    this.user,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      statId: json['stat_id'],
      userId: json['user_id'],
      tasksCompleted: json['tasks_completed'] ?? 0,
      tasksPending: json['tasks_pending'] ?? 0,
      habitsStreak: json['habits_streak'] ?? 0,
      habitsCompletionRate: (json['habits_completion_rate'] ?? 0.00).toDouble(),
      productivityScore: json['productivity_score'] ?? 0,
      loginFrequency: (json['login_frequency'] ?? 0.00).toDouble(),
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'])
          : null,
      aiInteractionCount: json['ai_interaction_count'] ?? 0,
      aiSuggestionAdoptionRate:
          (json['ai_suggestion_adoption_rate'] ?? 0.00).toDouble(),
      date: DateTime.parse(json['date']),
      user:
          json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (statId != null) 'stat_id': statId,
      'user_id': userId,
      'tasks_completed': tasksCompleted,
      'tasks_pending': tasksPending,
      'habits_streak': habitsStreak,
      'habits_completion_rate': habitsCompletionRate,
      'productivity_score': productivityScore,
      'login_frequency': loginFrequency,
      if (lastActiveDate != null)
        'last_active_date': lastActiveDate!.toIso8601String(),
      'ai_interaction_count': aiInteractionCount,
      'ai_suggestion_adoption_rate': aiSuggestionAdoptionRate,
      'date': date.toIso8601String(),
      if (user != null) 'user': user,
    };
  }

  UserStatistics copyWith({
    int? statId,
    int? userId,
    int? tasksCompleted,
    int? tasksPending,
    int? habitsStreak,
    double? habitsCompletionRate,
    int? productivityScore,
    double? loginFrequency,
    DateTime? lastActiveDate,
    int? aiInteractionCount,
    double? aiSuggestionAdoptionRate,
    DateTime? date,
    Map<String, dynamic>? user,
  }) {
    return UserStatistics(
      statId: statId ?? this.statId,
      userId: userId ?? this.userId,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksPending: tasksPending ?? this.tasksPending,
      habitsStreak: habitsStreak ?? this.habitsStreak,
      habitsCompletionRate: habitsCompletionRate ?? this.habitsCompletionRate,
      productivityScore: productivityScore ?? this.productivityScore,
      loginFrequency: loginFrequency ?? this.loginFrequency,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      aiInteractionCount: aiInteractionCount ?? this.aiInteractionCount,
      aiSuggestionAdoptionRate:
          aiSuggestionAdoptionRate ?? this.aiSuggestionAdoptionRate,
      date: date ?? this.date,
      user: user ?? this.user,
    );
  }
}
