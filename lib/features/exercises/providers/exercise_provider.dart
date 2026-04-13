import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';
import '../data/exercise_models.dart';
import '../data/exercise_repository.dart';
import '../data/exercise_local_repository.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(supabaseProvider));
});

final exerciseLocalRepositoryProvider =
    Provider<ExerciseLocalRepository>((ref) {
  return ExerciseLocalRepository(ref.watch(appDatabaseProvider));
});

// ── Exercise list provider ────────────────────────────────────────────────────

final exerciseListProvider =
    AsyncNotifierProvider<ExerciseListNotifier, List<Exercise>>(
  ExerciseListNotifier.new,
);

class ExerciseListNotifier extends AsyncNotifier<List<Exercise>> {
  @override
  Future<List<Exercise>> build() async {
    final local = ref.read(exerciseLocalRepositoryProvider);
    final hasCache = await local.hasExercises();

    if (hasCache) {
      final cached = await local.getAllExercises();
      _syncFromRemote();
      return cached;
    }

    final remote = ref.read(exerciseRepositoryProvider);
    final fresh = await remote.getAllExercises();
    await local.upsertExercises(fresh);
    return fresh;
  }

  Future<void> _syncFromRemote() async {
    final remote = ref.read(exerciseRepositoryProvider);
    final local = ref.read(exerciseLocalRepositoryProvider);

    final fresh = await remote.getAllExercises();
    if (fresh.isEmpty) return;
    await local.upsertExercises(fresh);

    state = AsyncData(fresh);
  }
}

// ── Filter state ──────────────────────────────────────────────────────────────

class ExerciseFilters {
  final String? muscle;
  final String? equipment;
  final bool stretchesOnly;

  const ExerciseFilters({
    this.muscle,
    this.equipment,
    this.stretchesOnly = false,
  });

  ExerciseFilters copyWith({
    String? muscle,
    String? equipment,
    bool? stretchesOnly,
    bool clearMuscle = false,
    bool clearEquipment = false,
  }) {
    return ExerciseFilters(
      muscle: clearMuscle ? null : (muscle ?? this.muscle),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
      stretchesOnly: stretchesOnly ?? this.stretchesOnly,
    );
  }

  bool get hasActiveFilters =>
      muscle != null || equipment != null || stretchesOnly;

  int get activeCount {
    int count = 0;
    if (muscle != null) count++;
    if (equipment != null) count++;
    if (stretchesOnly) count++;
    return count;
  }
}

final exerciseFiltersProvider =
    NotifierProvider<ExerciseFiltersNotifier, ExerciseFilters>(
  ExerciseFiltersNotifier.new,
);

class ExerciseFiltersNotifier extends Notifier<ExerciseFilters> {
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

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query.toLowerCase().trim();
  void clear() => state = '';
}

// ── Filtered exercise list ────────────────────────────────────────────────────

final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  final filters = ref.watch(exerciseFiltersProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  final exercises = exercisesAsync.asData?.value ?? [];

  return exercises.where((e) {
    if (filters.stretchesOnly && e.category != ExerciseCategory.stretch) {
      return false;
    }
    if (filters.muscle != null) {
      final muscleMatch =
          e.muscleGroups.any(
            (m) => m.toLowerCase() == filters.muscle!.toLowerCase(),
          ) ||
          e.secondaryMuscles.any(
            (m) => m.toLowerCase() == filters.muscle!.toLowerCase(),
          );
      if (!muscleMatch) return false;
    }
    if (filters.equipment != null) {
      final equipMatch = e.equipment.any(
        (eq) => eq.toLowerCase() == filters.equipment!.toLowerCase(),
      );
      if (!equipMatch) return false;
    }
    if (searchQuery.isNotEmpty &&
        !e.name.toLowerCase().contains(searchQuery)) {
      return false;
    }
    return true;
  }).toList();
});

// ── Options for filter sheet ──────────────────────────────────────────────────

final muscleGroupOptionsProvider = Provider<List<String>>((ref) {
  final exercises = ref.watch(exerciseListProvider).asData?.value ?? [];
  final muscles = <String>{};
  for (final e in exercises) {
    muscles.addAll(e.muscleGroups);
  }
  return muscles.toList()..sort();
});

final equipmentOptionsProvider = Provider<List<String>>((ref) {
  final exercises = ref.watch(exerciseListProvider).asData?.value ?? [];
  final equipment = <String>{};
  for (final e in exercises) {
    equipment.addAll(e.equipment);
  }
  return equipment.toList()..sort();
});