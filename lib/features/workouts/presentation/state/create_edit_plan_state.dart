import 'package:ember/features/workouts/data/plan_models.dart';

class PlanDayState {
  final int weekNumber;
  final int dayOfWeek;
  final bool isRestDay;
  final String? label;
  final List<String> routineIds;
  final List<String> routineTitles;

  const PlanDayState({
    required this.weekNumber,
    required this.dayOfWeek,
    this.isRestDay = false,
    this.label,
    this.routineIds = const [],
    this.routineTitles = const [],
  });

  PlanDayState copyWith({
    bool? isRestDay,
    String? label,
    List<String>? routineIds,
    List<String>? routineTitles,
  }) {
    return PlanDayState(
      weekNumber: weekNumber,
      dayOfWeek: dayOfWeek,
      isRestDay: isRestDay ?? this.isRestDay,
      label: label ?? this.label,
      routineIds: routineIds ?? this.routineIds,
      routineTitles: routineTitles ?? this.routineTitles,
    );
  }

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
}

class CreateEditPlanState {
  final String title;
  final String description;
  final int totalWeeks;
  final List<PlanDayState> days;
  final bool isSaving;

  const CreateEditPlanState({
    this.title = '',
    this.description = '',
    this.totalWeeks = 1,
    this.days = const [],
    this.isSaving = false,
  });

  CreateEditPlanState copyWith({
    String? title,
    String? description,
    int? totalWeeks,
    List<PlanDayState>? days,
    bool? isSaving,
  }) {
    return CreateEditPlanState(
      title: title ?? this.title,
      description: description ?? this.description,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      days: days ?? this.days,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  bool get isValid => title.trim().isNotEmpty && totalWeeks >= 1;

  int restDayCount(int weekNumber) =>
      days.where((d) => d.weekNumber == weekNumber && d.isRestDay).length;
}

List<PlanDayState> buildWeekDays(int weekNumber) {
  return List.generate(
    7,
    (i) => PlanDayState(weekNumber: weekNumber, dayOfWeek: i + 1),
  );
}

List<PlanDayState> mapPlanDaysToState(List<PlanDay> days) {
  return days
      .map(
        (d) => PlanDayState(
          weekNumber: d.weekNumber,
          dayOfWeek: d.dayOfWeek,
          isRestDay: d.isRestDay,
          label: d.label,
          routineIds: d.routines.map((r) => r.routineId).toList(),
          routineTitles: d.routines.map((r) => r.routineTitle ?? '').toList(),
        ),
      )
      .toList();
}

List<PlanDay> mapStateToPlanDays({
  required List<PlanDayState> days,
  required String? existingPlanId,
}) {
  return days.map((d) {
    final routines = List.generate(
      d.routineIds.length,
      (i) => PlanDayRoutineRef(
        id: 'new_$i',
        planDayId: '',
        routineId: d.routineIds[i],
        sortOrder: i,
        routineTitle: d.routineTitles[i],
      ),
    );
    return PlanDay(
      id: '',
      planId: existingPlanId ?? '',
      weekNumber: d.weekNumber,
      dayOfWeek: d.dayOfWeek,
      isRestDay: d.isRestDay,
      label: d.label,
      routines: routines,
    );
  }).toList();
}
