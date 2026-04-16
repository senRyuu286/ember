import '../../data/workout_models.dart';

abstract class IWorkoutRepository {
  Future<List<RoutineSummary>> getRoutineSummaries();
  Future<List<RoutineSummary>> forceFetchSummaries();
  Future<Routine?> getRoutineDetail(String routineId);

  Future<String> createRoutine({
    required String title,
    String? description,
    required List<RoutineExercise> exercises,
  });

  Future<void> updateRoutine({
    required String routineId,
    required String title,
    String? description,
    required List<RoutineExercise> exercises,
  });

  Future<void> deleteRoutine(String routineId);

  Future<void> finishSession({
    required String sessionId,
    required String routineId,
    required int durationSeconds,
    required double totalVolumeLbs,
    required List<LoggedSetData> loggedSets,
  });

  Future<String> startSession({
    required String routineId,
    required String routineName,
  });
}
