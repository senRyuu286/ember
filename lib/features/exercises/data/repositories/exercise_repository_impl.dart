import '../exercise_local_repository.dart';
import '../exercise_models.dart';
import '../exercise_repository.dart';
import '../../domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements IExerciseRepository {
  final ExerciseRepository _remote;
  final ExerciseLocalRepository _local;

  ExerciseRepositoryImpl({
    required ExerciseRepository remote,
    required ExerciseLocalRepository local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<bool> hasCachedExercises() {
    return _local.hasExercises();
  }

  @override
  Future<List<Exercise>> getCachedExercises() {
    return _local.getAllExercises();
  }

  @override
  Future<List<Exercise>> getRemoteExercises() {
    return _remote.getAllExercises();
  }

  @override
  Future<void> upsertExercises(List<Exercise> exercises) {
    return _local.upsertExercises(exercises);
  }
}
