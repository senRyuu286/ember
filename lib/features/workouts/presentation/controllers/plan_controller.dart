import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

import '../../data/plan_models.dart';
import '../../data/plan_repository.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/usecases/plan_usecases.dart';
import '../state/create_edit_plan_state.dart';

final planRepositoryProvider = Provider<IPlanRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final db = ref.watch(appDatabaseProvider);
  return PlanRepository(client, db.planDao);
});

final getPlanSummariesUseCaseProvider = Provider<GetPlanSummariesUseCase>((ref) {
  return GetPlanSummariesUseCase(ref.watch(planRepositoryProvider));
});

final getPlanDetailUseCaseProvider = Provider<GetPlanDetailUseCase>((ref) {
  return GetPlanDetailUseCase(ref.watch(planRepositoryProvider));
});

final savePlanUseCaseProvider = Provider<SavePlanUseCase>((ref) {
  return SavePlanUseCase(ref.watch(planRepositoryProvider));
});

final deletePlanUseCaseProvider = Provider<DeletePlanUseCase>((ref) {
  return DeletePlanUseCase(ref.watch(planRepositoryProvider));
});

final activatePlanUseCaseProvider = Provider<ActivatePlanUseCase>((ref) {
  return ActivatePlanUseCase(ref.watch(planRepositoryProvider));
});

final deactivatePlanUseCaseProvider = Provider<DeactivatePlanUseCase>((ref) {
  return DeactivatePlanUseCase(ref.watch(planRepositoryProvider));
});

class PlanListNotifier extends AsyncNotifier<List<WorkoutPlanSummary>> {
  @override
  Future<List<WorkoutPlanSummary>> build() async {
    ref.watch(currentUserProvider);
    final useCase = ref.read(getPlanSummariesUseCaseProvider);
    return useCase.execute();
  }

  Future<void> refresh() async {
    final useCase = ref.read(getPlanSummariesUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(useCase.refresh);
  }

  Future<void> deletePlan(String planId) async {
    final plans = state.asData?.value ?? const <WorkoutPlanSummary>[];
    WorkoutPlanSummary? plan;
    for (final p in plans) {
      if (p.id == planId) {
        plan = p;
        break;
      }
    }
    if (plan?.isActive == true) {
      throw Exception('Active plans cannot be deleted.');
    }

    final useCase = ref.read(deletePlanUseCaseProvider);
    await useCase.execute(planId);
    await refresh();
  }

  Future<void> activatePlan(String planId) async {
    final useCase = ref.read(activatePlanUseCaseProvider);
    await useCase.execute(planId);
    await refresh();
  }

  Future<void> deactivatePlan(String planId) async {
    final useCase = ref.read(deactivatePlanUseCaseProvider);
    await useCase.execute(planId);
    await refresh();
  }
}

class PlanDetailNotifier extends AsyncNotifier<WorkoutPlan?> {
  PlanDetailNotifier(this.arg);
  final String arg;

  @override
  Future<WorkoutPlan?> build() async {
    final useCase = ref.read(getPlanDetailUseCaseProvider);
    return useCase.execute(arg);
  }

  Future<void> refresh() async {
    final useCase = ref.read(getPlanDetailUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => useCase.execute(arg));
  }
}

class CreateEditPlanNotifier extends Notifier<CreateEditPlanState> {
  CreateEditPlanNotifier(this.arg);
  final WorkoutPlan? arg;

  @override
  CreateEditPlanState build() {
    final p = arg;
    if (p != null) {
      final days = mapPlanDaysToState(p.days);
      return CreateEditPlanState(
        title: p.title,
        description: p.description ?? '',
        totalWeeks: p.totalWeeks,
        days: days,
      );
    }
    return CreateEditPlanState(days: buildWeekDays(1));
  }

  void setTitle(String title) => state = state.copyWith(title: title);

  void setDescription(String d) => state = state.copyWith(description: d);

  void setTotalWeeks(int weeks) {
    final clamped = weeks.clamp(1, 52);
    final current = state.totalWeeks;
    List<PlanDayState> days = List.from(state.days);

    if (clamped > current) {
      for (int w = current + 1; w <= clamped; w++) {
        days.addAll(buildWeekDays(w));
      }
    } else {
      days = days.where((d) => d.weekNumber <= clamped).toList();
    }

    state = state.copyWith(totalWeeks: clamped, days: days);
  }

  void toggleRestDay(int weekNumber, int dayOfWeek) {
    final days = List<PlanDayState>.from(state.days);
    final idx = days.indexWhere(
      (d) => d.weekNumber == weekNumber && d.dayOfWeek == dayOfWeek,
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
      (d) => d.weekNumber == weekNumber && d.dayOfWeek == dayOfWeek,
    );
    if (idx == -1) return;
    final day = days[idx];
    if (day.isRestDay) return;

    final ids = List<String>.from(day.routineIds)..add(routineId);
    final titles = List<String>.from(day.routineTitles)..add(routineTitle);
    days[idx] = day.copyWith(routineIds: ids, routineTitles: titles);
    state = state.copyWith(days: days);
  }

  void removeRoutineFromDay(int weekNumber, int dayOfWeek, int routineIndex) {
    final days = List<PlanDayState>.from(state.days);
    final idx = days.indexWhere(
      (d) => d.weekNumber == weekNumber && d.dayOfWeek == dayOfWeek,
    );
    if (idx == -1) return;

    final day = days[idx];
    final ids = List<String>.from(day.routineIds)..removeAt(routineIndex);
    final titles = List<String>.from(day.routineTitles)..removeAt(routineIndex);
    days[idx] = day.copyWith(routineIds: ids, routineTitles: titles);
    state = state.copyWith(days: days);
  }

  Future<String?> save(String? existingPlanId) async {
    if (!state.isValid) return null;
    state = state.copyWith(isSaving: true);

    final saveUseCase = ref.read(savePlanUseCaseProvider);

    try {
      final planDays = mapStateToPlanDays(
        days: state.days,
        existingPlanId: existingPlanId,
      );

      if (existingPlanId != null) {
        await saveUseCase.update(
          planId: existingPlanId,
          title: state.title.trim(),
          description:
              state.description.trim().isEmpty ? null : state.description.trim(),
          totalWeeks: state.totalWeeks,
          days: planDays,
        );
        return existingPlanId;
      }

      return saveUseCase.create(
        title: state.title.trim(),
        description:
            state.description.trim().isEmpty ? null : state.description.trim(),
        totalWeeks: state.totalWeeks,
        days: planDays,
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
