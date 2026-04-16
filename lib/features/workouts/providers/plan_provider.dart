import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';
import '../data/plan_models.dart';
import '../data/plan_repository.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final db = ref.watch(appDatabaseProvider);
  return PlanRepository(client, db.planDao);
});

// ── Plan list ─────────────────────────────────────────────────────────────────

final planListProvider =
    AsyncNotifierProvider<PlanListNotifier, List<WorkoutPlanSummary>>(
  PlanListNotifier.new,
);

class PlanListNotifier
    extends AsyncNotifier<List<WorkoutPlanSummary>> {
  @override
  Future<List<WorkoutPlanSummary>> build() async {
    ref.watch(currentUserProvider);
    return await ref
        .read(planRepositoryProvider)
        .getPlanSummaries();
  }

  Future<void> refresh() async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(
    () => ref.read(planRepositoryProvider).forceFetchSummaries(),
  );
}

  Future<void> deletePlan(String planId) async {
    await ref.read(planRepositoryProvider).deletePlan(planId);
    await refresh();
  }

  Future<void> activatePlan(String planId) async {
    await ref.read(planRepositoryProvider).activatePlan(planId);
    await refresh();
  }

  Future<void> deactivatePlan(String planId) async {
    await ref
        .read(planRepositoryProvider)
        .deactivatePlan(planId);
    await refresh();
  }
}

// ── Plan detail ───────────────────────────────────────────────────────────────

final planDetailProvider =
    AsyncNotifierProvider.family<PlanDetailNotifier, WorkoutPlan?, String>(
  PlanDetailNotifier.new,
);

class PlanDetailNotifier extends AsyncNotifier<WorkoutPlan?> {
  PlanDetailNotifier(this.arg);
  final String arg;

  @override
  Future<WorkoutPlan?> build() async {
    return await ref
        .read(planRepositoryProvider)
        .getPlanDetail(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(planRepositoryProvider).getPlanDetail(arg),
    );
  }
}

// ── Create / Edit plan state ──────────────────────────────────────────────────

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
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
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

  int restDayCount(int weekNumber) => days
      .where((d) => d.weekNumber == weekNumber && d.isRestDay)
      .length;
}

List<PlanDayState> _buildWeekDays(int weekNumber) {
  return List.generate(
    7,
    (i) => PlanDayState(weekNumber: weekNumber, dayOfWeek: i + 1),
  );
}

final createEditPlanProvider = NotifierProvider.family<
    CreateEditPlanNotifier, CreateEditPlanState, WorkoutPlan?>(
  CreateEditPlanNotifier.new,
);

class CreateEditPlanNotifier
    extends Notifier<CreateEditPlanState> {
  CreateEditPlanNotifier(this.arg);
  final WorkoutPlan? arg;

  @override
  CreateEditPlanState build() {
    final p = arg;
    if (p != null) {
      final days = p.days.map((d) {
        return PlanDayState(
          weekNumber: d.weekNumber,
          dayOfWeek: d.dayOfWeek,
          isRestDay: d.isRestDay,
          label: d.label,
          routineIds:
              d.routines.map((r) => r.routineId).toList(),
          routineTitles:
              d.routines.map((r) => r.routineTitle ?? '').toList(),
        );
      }).toList();
      return CreateEditPlanState(
        title: p.title,
        description: p.description ?? '',
        totalWeeks: p.totalWeeks,
        days: days,
      );
    }
    return CreateEditPlanState(days: _buildWeekDays(1));
  }

  void setTitle(String title) =>
      state = state.copyWith(title: title);

  void setDescription(String d) =>
      state = state.copyWith(description: d);

  void setTotalWeeks(int weeks) {
    final clamped = weeks.clamp(1, 52);
    final current = state.totalWeeks;
    List<PlanDayState> days = List.from(state.days);

    if (clamped > current) {
      for (int w = current + 1; w <= clamped; w++) {
        days.addAll(_buildWeekDays(w));
      }
    } else {
      days = days.where((d) => d.weekNumber <= clamped).toList();
    }

    state = state.copyWith(totalWeeks: clamped, days: days);
  }

  void toggleRestDay(int weekNumber, int dayOfWeek) {
    final days = List<PlanDayState>.from(state.days);
    final idx = days.indexWhere(
      (d) =>
          d.weekNumber == weekNumber && d.dayOfWeek == dayOfWeek,
    );
    if (idx == -1) return;

    final day = days[idx];
    final currentRestCount = state.restDayCount(weekNumber);
    if (!day.isRestDay && currentRestCount >= 3) return;

    days[idx] = day.copyWith(isRestDay: !day.isRestDay);
    state = state.copyWith(days: days);
  }

  void addRoutineToDay(
    int weekNumber,
    int dayOfWeek,
    String routineId,
    String routineTitle,
  ) {
    final days = List<PlanDayState>.from(state.days);
    final idx = days.indexWhere(
      (d) =>
          d.weekNumber == weekNumber && d.dayOfWeek == dayOfWeek,
    );
    if (idx == -1) return;
    final day = days[idx];
    if (day.isRestDay) return;

    final ids = List<String>.from(day.routineIds)..add(routineId);
    final titles =
        List<String>.from(day.routineTitles)..add(routineTitle);
    days[idx] = day.copyWith(routineIds: ids, routineTitles: titles);
    state = state.copyWith(days: days);
  }

  void removeRoutineFromDay(
      int weekNumber, int dayOfWeek, int routineIndex) {
    final days = List<PlanDayState>.from(state.days);
    final idx = days.indexWhere(
      (d) =>
          d.weekNumber == weekNumber && d.dayOfWeek == dayOfWeek,
    );
    if (idx == -1) return;

    final day = days[idx];
    final ids = List<String>.from(day.routineIds)
      ..removeAt(routineIndex);
    final titles = List<String>.from(day.routineTitles)
      ..removeAt(routineIndex);
    days[idx] = day.copyWith(routineIds: ids, routineTitles: titles);
    state = state.copyWith(days: days);
  }

  Future<String?> save(
      PlanRepository repo, String? existingPlanId) async {
    if (!state.isValid) return null;
    state = state.copyWith(isSaving: true);

    try {
      final planDays = state.days.map((d) {
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

      if (existingPlanId != null) {
        await repo.updatePlan(
          planId: existingPlanId,
          title: state.title.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          totalWeeks: state.totalWeeks,
          days: planDays,
        );
        return existingPlanId;
      } else {
        return await repo.createPlan(
          title: state.title.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          totalWeeks: state.totalWeeks,
          days: planDays,
        );
      }
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}