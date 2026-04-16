import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';
import '../data/workout_models.dart';
import '../data/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final db = ref.watch(appDatabaseProvider);
  return WorkoutRepository(client, db.routineDao);
});

// ── Routine list ──────────────────────────────────────────────────────────────

final routineListProvider =
    AsyncNotifierProvider<RoutineListNotifier, List<RoutineSummary>>(
  RoutineListNotifier.new,
);

class RoutineListNotifier extends AsyncNotifier<List<RoutineSummary>> {
  @override
  Future<List<RoutineSummary>> build() async {
    ref.watch(currentUserProvider);
    return await ref
        .read(workoutRepositoryProvider)
        .getRoutineSummaries();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(workoutRepositoryProvider)
          .forceFetchSummaries(),
    );
  }

  Future<void> deleteRoutine(String routineId) async {
    await ref
        .read(workoutRepositoryProvider)
        .deleteRoutine(routineId);
    await refresh();
  }
}

// ── Routine detail ────────────────────────────────────────────────────────────

final routineDetailProvider =
    AsyncNotifierProvider.family<RoutineDetailNotifier, Routine?, String>(
  RoutineDetailNotifier.new,
);

class RoutineDetailNotifier extends AsyncNotifier<Routine?> {
  RoutineDetailNotifier(this.arg);
  final String arg;

  @override
  Future<Routine?> build() async {
    return await ref
        .read(workoutRepositoryProvider)
        .getRoutineDetail(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(workoutRepositoryProvider)
          .getRoutineDetail(arg),
    );
  }
}

// ── Create / Edit routine state ───────────────────────────────────────────────

class CreateEditRoutineState {
  final String title;
  final String description;
  final List<RoutineExercise> exercises;
  final bool isSaving;

  const CreateEditRoutineState({
    this.title = '',
    this.description = '',
    this.exercises = const [],
    this.isSaving = false,
  });

  CreateEditRoutineState copyWith({
    String? title,
    String? description,
    List<RoutineExercise>? exercises,
    bool? isSaving,
  }) {
    return CreateEditRoutineState(
      title: title ?? this.title,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  bool get isValid => title.trim().isNotEmpty && exercises.isNotEmpty;
}

final createEditRoutineProvider = NotifierProvider.family<
    CreateEditRoutineNotifier, CreateEditRoutineState, Routine?>(
  CreateEditRoutineNotifier.new,
);

class CreateEditRoutineNotifier extends Notifier<CreateEditRoutineState> {
  CreateEditRoutineNotifier(this.arg);
  final Routine? arg;

  @override
  CreateEditRoutineState build() {
    final r = arg;
    if (r != null) {
      return CreateEditRoutineState(
        title: r.title,
        description: r.description ?? '',
        exercises: List.from(r.exercises),
      );
    }
    return const CreateEditRoutineState();
  }

  void setTitle(String title) => state = state.copyWith(title: title);
  void setDescription(String description) =>
      state = state.copyWith(description: description);

  void addExercise(RoutineExercise exercise) {
    final updated = List<RoutineExercise>.from(state.exercises)..add(exercise);
    state = state.copyWith(exercises: updated);
  }

  void removeExercise(int index) {
    final updated =
        List<RoutineExercise>.from(state.exercises)..removeAt(index);
    state = state.copyWith(exercises: updated);
  }

  void reorderExercises(int oldIndex, int newIndex) {
    final updated = List<RoutineExercise>.from(state.exercises);
    if (newIndex > oldIndex) newIndex--;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(exercises: updated);
  }

  void updateExercise(int index, RoutineExercise updated) {
    final list = List<RoutineExercise>.from(state.exercises);
    list[index] = updated;
    state = state.copyWith(exercises: list);
  }

  Future<String?> save(
      WorkoutRepository repo, String? existingRoutineId) async {
    if (!state.isValid) return null;
    state = state.copyWith(isSaving: true);
    try {
      if (existingRoutineId != null) {
        await repo.updateRoutine(
          routineId: existingRoutineId,
          title: state.title.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          exercises: state.exercises,
        );
        return existingRoutineId;
      } else {
        return await repo.createRoutine(
          title: state.title.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          exercises: state.exercises,
        );
      }
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

// ── Workout summary (passed to completion screen) ─────────────────────────────

/// Per-exercise breakdown for the completion screen.
class ExerciseSummary {
  final String exerciseName;
  final int setsCompleted;
  final int totalReps;
  final double? totalWeightLbs;
  final String weightUnit;

  const ExerciseSummary({
    required this.exerciseName,
    required this.setsCompleted,
    required this.totalReps,
    required this.totalWeightLbs,
    required this.weightUnit,
  });
}

/// Full workout summary passed to the completion screen as route extra.
class WorkoutSummary {
  final String routineTitle;
  final int durationSeconds;
  final int totalSetsCompleted;
  final double totalVolumeLbs;
  final List<ExerciseSummary> exercises;

  const WorkoutSummary({
    required this.routineTitle,
    required this.durationSeconds,
    required this.totalSetsCompleted,
    required this.totalVolumeLbs,
    required this.exercises,
  });

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) {
      return '${h}h ${m}m ${s}s';
    }
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

// ── Active session state ──────────────────────────────────────────────────────

class SetLog {
  final String exerciseId;
  final int setNumber;
  final int? reps;
  final double? weight;
  final bool isCompleted;

  const SetLog({
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.isCompleted = false,
  });

  SetLog copyWith({int? reps, double? weight, bool? isCompleted}) {
    return SetLog(
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class SessionState {
  final String sessionId;
  final Routine routine;
  final int currentExerciseIndex;
  final int currentSetIndex;
  final Map<String, List<SetLog>> setLogs;
  final DateTime startedAt;
  final bool isResting;
  final int restSecondsRemaining;
  final bool isFinished;

  const SessionState({
    required this.sessionId,
    required this.routine,
    required this.currentExerciseIndex,
    required this.currentSetIndex,
    required this.setLogs,
    required this.startedAt,
    this.isResting = false,
    this.restSecondsRemaining = 0,
    this.isFinished = false,
  });

  RoutineExercise get currentExercise =>
      routine.exercises[currentExerciseIndex];

  RoutineExercise? get nextExercise {
    if (currentSetIndex < currentExercise.targetSets - 1) return null;
    final nextIdx = currentExerciseIndex + 1;
    if (nextIdx < routine.exercises.length) {
      return routine.exercises[nextIdx];
    }
    return null;
  }

  bool get isLastExercise =>
      currentExerciseIndex == routine.exercises.length - 1;
  bool get isLastSet => currentSetIndex == currentExercise.targetSets - 1;

  int get completedSetsCount {
    int count = 0;
    for (final logs in setLogs.values) {
      count += logs.where((s) => s.isCompleted).length;
    }
    return count;
  }

  int get totalSetsCount =>
      routine.exercises.fold(0, (sum, e) => sum + e.targetSets);

  int get completedExercisesCount => setLogs.entries.where((entry) {
        final ex = routine.exercises.firstWhere(
          (e) => e.exerciseId == entry.key,
          orElse: () => routine.exercises.first,
        );
        return entry.value.where((s) => s.isCompleted).length >= ex.targetSets;
      }).length;

  SessionState copyWith({
    int? currentExerciseIndex,
    int? currentSetIndex,
    Map<String, List<SetLog>>? setLogs,
    bool? isResting,
    int? restSecondsRemaining,
    bool? isFinished,
  }) {
    return SessionState(
      sessionId: sessionId,
      routine: routine,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      setLogs: setLogs ?? this.setLogs,
      startedAt: startedAt,
      isResting: isResting ?? this.isResting,
      restSecondsRemaining:
          restSecondsRemaining ?? this.restSecondsRemaining,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

final activeSessionProvider =
    NotifierProvider<ActiveSessionNotifier, SessionState?>(
  ActiveSessionNotifier.new,
);

class ActiveSessionNotifier extends Notifier<SessionState?> {
  @override
  SessionState? build() => null;

  void startSession(String sessionId, Routine routine) {
    final logs = <String, List<SetLog>>{};
    for (final ex in routine.exercises) {
      logs[ex.exerciseId] = List.generate(
        ex.targetSets,
        (i) => SetLog(
          exerciseId: ex.exerciseId,
          setNumber: i + 1,
          reps: ex.targetReps,
          weight: ex.targetWeight,
        ),
      );
    }
    state = SessionState(
      sessionId: sessionId,
      routine: routine,
      currentExerciseIndex: 0,
      currentSetIndex: 0,
      setLogs: logs,
      startedAt: DateTime.now(),
    );
  }

  void updateCurrentSetLog({int? reps, double? weight}) {
    final s = state;
    if (s == null) return;
    final exId = s.currentExercise.exerciseId;
    final logs = Map<String, List<SetLog>>.from(s.setLogs);
    final exLogs = List<SetLog>.from(logs[exId] ?? []);
    if (s.currentSetIndex < exLogs.length) {
      exLogs[s.currentSetIndex] =
          exLogs[s.currentSetIndex].copyWith(reps: reps, weight: weight);
    }
    logs[exId] = exLogs;
    state = s.copyWith(setLogs: logs);
  }

  void completeCurrentSet(int restSeconds) {
    final s = state;
    if (s == null) return;
    final exId = s.currentExercise.exerciseId;
    final logs = Map<String, List<SetLog>>.from(s.setLogs);
    final exLogs = List<SetLog>.from(logs[exId] ?? []);

    if (s.currentSetIndex < exLogs.length) {
      exLogs[s.currentSetIndex] =
          exLogs[s.currentSetIndex].copyWith(isCompleted: true);
    }
    logs[exId] = exLogs;

    final isLastSet = s.currentSetIndex >= s.currentExercise.targetSets - 1;
    final isLastExercise =
        s.currentExerciseIndex >= s.routine.exercises.length - 1;

    if (isLastSet && isLastExercise) {
      state = s.copyWith(setLogs: logs, isFinished: true);
      return;
    }

    if (isLastSet) {
      state = s.copyWith(
        setLogs: logs,
        currentExerciseIndex: s.currentExerciseIndex + 1,
        currentSetIndex: 0,
        isResting: true,
        restSecondsRemaining: restSeconds,
      );
    } else {
      state = s.copyWith(
        setLogs: logs,
        currentSetIndex: s.currentSetIndex + 1,
        isResting: true,
        restSecondsRemaining: restSeconds,
      );
    }
  }

  void tickRest() {
    final s = state;
    if (s == null || !s.isResting) return;
    if (s.restSecondsRemaining <= 1) {
      state = s.copyWith(isResting: false, restSecondsRemaining: 0);
    } else {
      state = s.copyWith(restSecondsRemaining: s.restSecondsRemaining - 1);
    }
  }

  void skipRest() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(isResting: false, restSecondsRemaining: 0);
  }

  void clearSession() => state = null;

  List<LoggedSetData> collectLoggedSets() {
    final s = state;
    if (s == null) return [];
    final result = <LoggedSetData>[];
    for (final entry in s.setLogs.entries) {
      for (final log in entry.value.where((l) => l.isCompleted)) {
        result.add(LoggedSetData(
          exerciseId: entry.key,
          setNumber: log.setNumber,
          reps: log.reps,
          weight: log.weight,
          unit: s.routine.exercises
              .firstWhere(
                (e) => e.exerciseId == entry.key,
                orElse: () => s.routine.exercises.first,
              )
              .targetWeightUnit,
          completedAt: DateTime.now(),
        ));
      }
    }
    return result;
  }

  double totalVolumeLbs() {
    final s = state;
    if (s == null) return 0;
    double total = 0;
    for (final entry in s.setLogs.entries) {
      for (final log in entry.value.where((l) => l.isCompleted)) {
        if (log.weight != null && log.reps != null) {
          final ex = s.routine.exercises.firstWhere(
            (e) => e.exerciseId == entry.key,
            orElse: () => s.routine.exercises.first,
          );
          final weightLbs = ex.targetWeightUnit == 'kg'
              ? (log.weight! * 2.20462)
              : log.weight!;
          total += weightLbs * log.reps!;
        }
      }
    }
    return total;
  }

  /// Builds a WorkoutSummary from the current session state.
  /// Call this BEFORE clearSession().
  WorkoutSummary buildSummary(int durationSeconds) {
    final s = state;
    if (s == null) {
      return const WorkoutSummary(
        routineTitle: '',
        durationSeconds: 0,
        totalSetsCompleted: 0,
        totalVolumeLbs: 0,
        exercises: [],
      );
    }

    final exerciseSummaries = <ExerciseSummary>[];
    for (final ex in s.routine.exercises) {
      final logs =
          (s.setLogs[ex.exerciseId] ?? []).where((l) => l.isCompleted).toList();
      if (logs.isEmpty) continue;

      final totalReps = logs.fold<int>(0, (sum, l) => sum + (l.reps ?? 0));
      double? totalWeight;
      if (logs.any((l) => l.weight != null)) {
        totalWeight = logs.fold<double>(0, (sum, l) {
          if (l.weight == null || l.reps == null) return sum;
          final w = ex.targetWeightUnit == 'kg'
              ? l.weight! * 2.20462
              : l.weight!;
          return sum + w * l.reps!;
        });
      }

      exerciseSummaries.add(ExerciseSummary(
        exerciseName: ex.exercise?.name ?? ex.exerciseId,
        setsCompleted: logs.length,
        totalReps: totalReps,
        totalWeightLbs: totalWeight,
        weightUnit: ex.targetWeightUnit,
      ));
    }

    return WorkoutSummary(
      routineTitle: s.routine.title,
      durationSeconds: durationSeconds,
      totalSetsCompleted: s.completedSetsCount,
      totalVolumeLbs: totalVolumeLbs(),
      exercises: exerciseSummaries,
    );
  }
}