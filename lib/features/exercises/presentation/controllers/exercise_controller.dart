import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

import '../../data/exercise_local_repository.dart';
import '../../data/exercise_models.dart';
import '../../data/exercise_repository.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/usecases/filter_exercises_usecase.dart';
import '../state/exercise_filters.dart';

final exerciseRepositoryProvider = Provider<IExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(
    remote: ExerciseRepository(ref.watch(supabaseProvider)),
    local: ExerciseLocalRepository(ref.watch(appDatabaseProvider)),
  );
});

final filterExercisesUseCaseProvider = Provider<FilterExercisesUseCase>((ref) {
  return FilterExercisesUseCase();
});

class ExerciseListController extends AsyncNotifier<List<Exercise>> {
  @override
  Future<List<Exercise>> build() async {
    final repository = ref.read(exerciseRepositoryProvider);
    final hasCache = await repository.hasCachedExercises();

    if (hasCache) {
      final cached = await repository.getCachedExercises();
      _syncFromRemote();
      return cached;
    }

    final fresh = await repository.getRemoteExercises();
    await repository.upsertExercises(fresh);
    return fresh;
  }

  Future<void> _syncFromRemote() async {
    final repository = ref.read(exerciseRepositoryProvider);

    final fresh = await repository.getRemoteExercises();
    if (fresh.isEmpty) return;

    await repository.upsertExercises(fresh);
    state = AsyncData(fresh);
  }
}

class ExerciseFiltersController extends Notifier<ExerciseFilters> {
  @override
  ExerciseFilters build() => const ExerciseFilters();

  void setMuscle(String? muscle) {
    state = state.copyWith(
      muscle: muscle,
      clearMuscle: muscle == null,
    );
  }

  void setEquipment(String? equipment) {
    state = state.copyWith(
      equipment: equipment,
      clearEquipment: equipment == null,
    );
  }

  void setStretchesOnly(bool value) {
    state = state.copyWith(stretchesOnly: value);
  }

  void clearAll() {
    state = const ExerciseFilters();
  }
}

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query.toLowerCase().trim();

  void clear() => state = '';
}
