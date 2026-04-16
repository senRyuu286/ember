import '../../data/exercise_models.dart';

abstract class IExerciseRepository {
  Future<bool> hasCachedExercises();
  Future<List<Exercise>> getCachedExercises();
  Future<List<Exercise>> getRemoteExercises();
  Future<void> upsertExercises(List<Exercise> exercises);
}
