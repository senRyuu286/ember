class PlanDayRoutineRef {
  final String id;
  final String planDayId;
  final String routineId;
  final int sortOrder;

  // Denormalized for display — populated when loading plan detail
  final String? routineTitle;

  const PlanDayRoutineRef({
    required this.id,
    required this.planDayId,
    required this.routineId,
    required this.sortOrder,
    this.routineTitle,
  });

  factory PlanDayRoutineRef.fromMap(Map<String, dynamic> map,
      {String? routineTitle}) {
    return PlanDayRoutineRef(
      id: map['id'] as String,
      planDayId: map['plan_day_id'] as String,
      routineId: map['routine_id'] as String,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      routineTitle: routineTitle,
    );
  }
}

class PlanDay {
  final String id;
  final String planId;
  final int weekNumber;
  final int dayOfWeek; // 1=Mon, 7=Sun
  final bool isRestDay;
  final String? label;
  final List<PlanDayRoutineRef> routines;

  const PlanDay({
    required this.id,
    required this.planId,
    required this.weekNumber,
    required this.dayOfWeek,
    required this.isRestDay,
    required this.label,
    required this.routines,
  });

  String get dayName {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[(dayOfWeek - 1).clamp(0, 6)];
  }

  String get shortDayName {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(dayOfWeek - 1).clamp(0, 6)];
  }

  PlanDay copyWith({
    bool? isRestDay,
    String? label,
    List<PlanDayRoutineRef>? routines,
  }) {
    return PlanDay(
      id: id,
      planId: planId,
      weekNumber: weekNumber,
      dayOfWeek: dayOfWeek,
      isRestDay: isRestDay ?? this.isRestDay,
      label: label ?? this.label,
      routines: routines ?? this.routines,
    );
  }

  factory PlanDay.fromMap(Map<String, dynamic> map,
      {List<PlanDayRoutineRef> routines = const []}) {
    return PlanDay(
      id: map['id'] as String,
      planId: map['plan_id'] as String,
      weekNumber: (map['week_number'] as int?) ?? 1,
      dayOfWeek: (map['day_of_week'] as int?) ?? 1,
      isRestDay: (map['is_rest_day'] as bool?) ?? false,
      label: map['label'] as String?,
      routines: routines,
    );
  }
}

class WorkoutPlan {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final bool isBuiltIn;
  final int totalWeeks;
  final bool isActive;
  final DateTime? startedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PlanDay> days;

  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isBuiltIn,
    required this.totalWeeks,
    required this.isActive,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
  });

  bool get isOwned => !isBuiltIn && userId != null;

  /// Returns the current week index (0-based) based on startedAt.
  /// Returns null if the plan is not active.
  int? get currentWeekIndex {
    if (!isActive || startedAt == null) return null;
    final daysSinceStart = DateTime.now().difference(startedAt!).inDays;
    final week = daysSinceStart ~/ 7;
    return week.clamp(0, totalWeeks - 1);
  }

  /// Returns the current day of week (1=Mon, 7=Sun) based on today.
  int get todayDayOfWeek {
    return DateTime.now().weekday; // dart weekday: 1=Mon, 7=Sun
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map,
      {List<PlanDay> days = const []}) {
    return WorkoutPlan(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      isBuiltIn: (map['is_built_in'] as bool?) ?? false,
      totalWeeks: (map['total_weeks'] as int?) ?? 1,
      isActive: (map['is_active'] as bool?) ?? false,
      startedAt: map['started_at'] != null
          ? DateTime.parse(map['started_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      days: days,
    );
  }
}

/// Lightweight summary used in the plans list. No days loaded.
class WorkoutPlanSummary {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final bool isBuiltIn;
  final int totalWeeks;
  final bool isActive;
  final DateTime? startedAt;

  const WorkoutPlanSummary({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isBuiltIn,
    required this.totalWeeks,
    required this.isActive,
    this.startedAt,
  });

  bool get isOwned => !isBuiltIn && userId != null;

  String get durationLabel =>
      totalWeeks == 1 ? '1 week' : '$totalWeeks weeks';
}