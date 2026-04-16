import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ember/features/workouts/data/workout_models.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';

import '../../data/repositories/session_repository_impl.dart';
import '../../domain/entities/session_entities.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/usecases/session_metrics_usecase.dart';
import '../../domain/usecases/session_state_machine_usecase.dart';

final sessionRepositoryProvider = Provider<ISessionRepository>((ref) {
  return SessionRepositoryImpl(ref.watch(workoutRepositoryProvider));
});

final sessionStateMachineUseCaseProvider = Provider<SessionStateMachineUseCase>((ref) {
  return SessionStateMachineUseCase();
});

final sessionMetricsUseCaseProvider = Provider<SessionMetricsUseCase>((ref) {
  return SessionMetricsUseCase();
});

class SessionController extends Notifier<SessionState?> {
  @override
  SessionState? build() => null;

  void startSession(String sessionId, Routine routine) {
    final stateMachine = ref.read(sessionStateMachineUseCaseProvider);
    state = stateMachine.startSession(sessionId, routine);
  }

  void updateCurrentSetLog({int? reps, double? weight}) {
    final current = state;
    if (current == null) return;

    final stateMachine = ref.read(sessionStateMachineUseCaseProvider);
    state = stateMachine.updateCurrentSetLog(current, reps: reps, weight: weight);
  }

  void completeCurrentSet(int restSeconds) {
    final current = state;
    if (current == null) return;

    final stateMachine = ref.read(sessionStateMachineUseCaseProvider);
    state = stateMachine.completeCurrentSet(current, restSeconds);
  }

  void tickRest() {
    final current = state;
    if (current == null) return;

    final stateMachine = ref.read(sessionStateMachineUseCaseProvider);
    state = stateMachine.tickRest(current);
  }

  void skipRest() {
    final current = state;
    if (current == null) return;

    final stateMachine = ref.read(sessionStateMachineUseCaseProvider);
    state = stateMachine.skipRest(current);
  }

  double totalVolumeLbs() {
    final current = state;
    if (current == null) return 0;

    final metrics = ref.read(sessionMetricsUseCaseProvider);
    return metrics.totalVolumeLbs(current);
  }

  WorkoutSummary buildSummary(int durationSeconds) {
    final current = state;
    if (current == null) {
      return const WorkoutSummary(
        routineTitle: '',
        durationSeconds: 0,
        totalSetsCompleted: 0,
        totalVolumeLbs: 0,
        exercises: [],
      );
    }

    final metrics = ref.read(sessionMetricsUseCaseProvider);
    return metrics.buildSummary(current, durationSeconds);
  }

  Future<void> persistSession(int durationSeconds) async {
    final current = state;
    if (current == null) return;

    final metrics = ref.read(sessionMetricsUseCaseProvider);
    final repository = ref.read(sessionRepositoryProvider);

    await repository.finishSession(
      sessionId: current.sessionId,
      routineId: current.routine.id,
      durationSeconds: durationSeconds,
      totalVolumeLbs: metrics.totalVolumeLbs(current),
      completedSets: metrics.collectCompletedSetLogs(current),
    );
  }

  void clearSession() => state = null;
}
