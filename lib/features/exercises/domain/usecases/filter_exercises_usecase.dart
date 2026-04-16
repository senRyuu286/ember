import '../../data/exercise_models.dart';
import '../../presentation/state/exercise_filters.dart';

class FilterExercisesUseCase {
  List<Exercise> execute({
    required List<Exercise> exercises,
    required ExerciseFilters filters,
    required String searchQuery,
  }) {
    return exercises.where((e) {
      if (filters.stretchesOnly && e.category != ExerciseCategory.stretch) {
        return false;
      }

      if (filters.muscle != null) {
        final muscle = filters.muscle!.toLowerCase();
        final muscleMatch =
            e.muscleGroups.any((m) => m.toLowerCase() == muscle) ||
            e.secondaryMuscles.any((m) => m.toLowerCase() == muscle);
        if (!muscleMatch) return false;
      }

      if (filters.equipment != null) {
        final equip = filters.equipment!.toLowerCase();
        final equipMatch = e.equipment.any((eq) => eq.toLowerCase() == equip);
        if (!equipMatch) return false;
      }

      if (searchQuery.isNotEmpty && !e.name.toLowerCase().contains(searchQuery)) {
        return false;
      }

      return true;
    }).toList();
  }
}
