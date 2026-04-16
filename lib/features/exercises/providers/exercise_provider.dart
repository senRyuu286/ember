import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise_models.dart';
import '../presentation/controllers/exercise_controller.dart';
import '../presentation/state/exercise_filters.dart';

final exerciseListProvider =
    AsyncNotifierProvider<ExerciseListController, List<Exercise>>(
  ExerciseListController.new,
);

final exerciseFiltersProvider =
    NotifierProvider<ExerciseFiltersController, ExerciseFilters>(
  ExerciseFiltersController.new,
);

final searchQueryProvider =
    NotifierProvider<SearchQueryController, String>(
  SearchQueryController.new,
);

final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  final filters = ref.watch(exerciseFiltersProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final filterUseCase = ref.watch(filterExercisesUseCaseProvider);

  final exercises = exercisesAsync.asData?.value ?? [];

  return filterUseCase.execute(
    exercises: exercises,
    filters: filters,
    searchQuery: searchQuery,
  );
});

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