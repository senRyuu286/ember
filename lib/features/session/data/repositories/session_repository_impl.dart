import 'package:ember/features/workouts/data/workout_models.dart';
import 'package:ember/features/workouts/domain/repositories/workout_repository.dart';

import '../../domain/entities/session_entities.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements ISessionRepository {
  final IWorkoutRepository _workoutRepository;

  SessionRepositoryImpl(this._workoutRepository);

  @override
  Future<void> finishSession({
    required String sessionId,
    required String routineId,
    required int durationSeconds,
    required double totalVolumeLbs,
    required List<CompletedSetLog> completedSets,
  }) {
    final loggedSets = completedSets
        .map(
          (s) => LoggedSetData(
            exerciseId: s.exerciseId,
            setNumber: s.setNumber,
            reps: s.reps,
            weight: s.weight,
            unit: s.unit,
            completedAt: s.completedAt,
          ),
        )
        .toList();

    return _workoutRepository.finishSession(
      sessionId: sessionId,
      routineId: routineId,
      durationSeconds: durationSeconds,
      totalVolumeLbs: totalVolumeLbs,
      loggedSets: loggedSets,
    );
  }
}
