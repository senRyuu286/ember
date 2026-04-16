import '../../data/workout_models.dart';
import '../repositories/workout_repository.dart';

class GetRoutineSummariesUseCase {
  final IWorkoutRepository _repository;

  GetRoutineSummariesUseCase(this._repository);

  Future<List<RoutineSummary>> execute() => _repository.getRoutineSummaries();

  Future<List<RoutineSummary>> refresh() => _repository.forceFetchSummaries();
}

class GetRoutineDetailUseCase {
  final IWorkoutRepository _repository;

  GetRoutineDetailUseCase(this._repository);

  Future<Routine?> execute(String routineId) {
    return _repository.getRoutineDetail(routineId);
  }
}

class SaveRoutineUseCase {
  final IWorkoutRepository _repository;

  SaveRoutineUseCase(this._repository);

  Future<String> create({
    required String title,
    String? description,
    required List<RoutineExercise> exercises,
  }) {
    return _repository.createRoutine(
      title: title,
      description: description,
      exercises: exercises,
    );
  }

  Future<void> update({
    required String routineId,
    required String title,
    String? description,
    required List<RoutineExercise> exercises,
  }) {
    return _repository.updateRoutine(
      routineId: routineId,
      title: title,
      description: description,
      exercises: exercises,
    );
  }
}

class DeleteRoutineUseCase {
  final IWorkoutRepository _repository;

  DeleteRoutineUseCase(this._repository);

  Future<void> execute(String routineId) {
    return _repository.deleteRoutine(routineId);
  }
}
