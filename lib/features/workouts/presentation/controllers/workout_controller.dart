import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

import '../../data/workout_models.dart';
import '../../data/workout_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/routine_usecases.dart';
import '../state/create_edit_routine_state.dart';

final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  final db = ref.watch(appDatabaseProvider);
  return WorkoutRepository(client, db.routineDao);
});

final getRoutineSummariesUseCaseProvider = Provider<GetRoutineSummariesUseCase>((ref) {
  return GetRoutineSummariesUseCase(ref.watch(workoutRepositoryProvider));
});

final getRoutineDetailUseCaseProvider = Provider<GetRoutineDetailUseCase>((ref) {
  return GetRoutineDetailUseCase(ref.watch(workoutRepositoryProvider));
});

final saveRoutineUseCaseProvider = Provider<SaveRoutineUseCase>((ref) {
  return SaveRoutineUseCase(ref.watch(workoutRepositoryProvider));
});

final deleteRoutineUseCaseProvider = Provider<DeleteRoutineUseCase>((ref) {
  return DeleteRoutineUseCase(ref.watch(workoutRepositoryProvider));
});

class RoutineListNotifier extends AsyncNotifier<List<RoutineSummary>> {
  @override
  Future<List<RoutineSummary>> build() async {
    ref.watch(currentUserProvider);
    final useCase = ref.read(getRoutineSummariesUseCaseProvider);
    return useCase.execute();
  }

  Future<void> refresh() async {
    final useCase = ref.read(getRoutineSummariesUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(useCase.refresh);
  }

  Future<void> deleteRoutine(String routineId) async {
    final useCase = ref.read(deleteRoutineUseCaseProvider);
    await useCase.execute(routineId);
    await refresh();
  }
}

class RoutineDetailNotifier extends AsyncNotifier<Routine?> {
  RoutineDetailNotifier(this.arg);
  final String arg;

  @override
  Future<Routine?> build() async {
    final useCase = ref.read(getRoutineDetailUseCaseProvider);
    return useCase.execute(arg);
  }

  Future<void> refresh() async {
    final useCase = ref.read(getRoutineDetailUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => useCase.execute(arg));
  }
}

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

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void addExercise(RoutineExercise exercise) {
    final updated = List<RoutineExercise>.from(state.exercises)..add(exercise);
    state = state.copyWith(exercises: updated);
  }

  void removeExercise(int index) {
    final updated = List<RoutineExercise>.from(state.exercises)..removeAt(index);
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

  Future<String?> save(String? existingRoutineId) async {
    if (!state.isValid) return null;

    final saveUseCase = ref.read(saveRoutineUseCaseProvider);
    state = state.copyWith(isSaving: true);

    try {
      if (existingRoutineId != null) {
        await saveUseCase.update(
          routineId: existingRoutineId,
          title: state.title.trim(),
          description:
              state.description.trim().isEmpty ? null : state.description.trim(),
          exercises: state.exercises,
        );
        return existingRoutineId;
      }

      return saveUseCase.create(
        title: state.title.trim(),
        description:
            state.description.trim().isEmpty ? null : state.description.trim(),
        exercises: state.exercises,
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
