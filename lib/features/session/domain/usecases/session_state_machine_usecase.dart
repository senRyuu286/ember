import 'package:ember/features/workouts/data/workout_models.dart';

import '../entities/session_entities.dart';

class SessionStateMachineUseCase {
  SessionState startSession(String sessionId, Routine routine) {
    final logs = <String, List<SetLog>>{};
    for (final ex in routine.exercises) {
      logs[ex.exerciseId] = List.generate(
        ex.targetSets,
        (i) => SetLog(
          exerciseId: ex.exerciseId,
          setNumber: i + 1,
          reps: ex.targetReps,
          weight: ex.targetWeight,
        ),
      );
    }

    return SessionState(
      sessionId: sessionId,
      routine: routine,
      currentExerciseIndex: 0,
      currentSetIndex: 0,
      setLogs: logs,
      startedAt: DateTime.now(),
    );
  }

  SessionState updateCurrentSetLog(
    SessionState state, {
    int? reps,
    double? weight,
  }) {
    final exId = state.currentExercise.exerciseId;
    final logs = Map<String, List<SetLog>>.from(state.setLogs);
    final exLogs = List<SetLog>.from(logs[exId] ?? []);

    if (state.currentSetIndex < exLogs.length) {
      exLogs[state.currentSetIndex] =
          exLogs[state.currentSetIndex].copyWith(reps: reps, weight: weight);
    }

    logs[exId] = exLogs;
    return state.copyWith(setLogs: logs);
  }

  SessionState completeCurrentSet(SessionState state, int restSeconds) {
    final exId = state.currentExercise.exerciseId;
    final logs = Map<String, List<SetLog>>.from(state.setLogs);
    final exLogs = List<SetLog>.from(logs[exId] ?? []);

    if (state.currentSetIndex < exLogs.length) {
      exLogs[state.currentSetIndex] =
          exLogs[state.currentSetIndex].copyWith(isCompleted: true);
    }
    logs[exId] = exLogs;

    final isLastSet = state.currentSetIndex >= state.currentExercise.targetSets - 1;
    final isLastExercise = state.currentExerciseIndex >= state.routine.exercises.length - 1;

    if (isLastSet && isLastExercise) {
      return state.copyWith(setLogs: logs, isFinished: true);
    }

    if (isLastSet) {
      return state.copyWith(
        setLogs: logs,
        currentExerciseIndex: state.currentExerciseIndex + 1,
        currentSetIndex: 0,
        isResting: true,
        restSecondsRemaining: restSeconds,
      );
    }

    return state.copyWith(
      setLogs: logs,
      currentSetIndex: state.currentSetIndex + 1,
      isResting: true,
      restSecondsRemaining: restSeconds,
    );
  }

  SessionState tickRest(SessionState state) {
    if (!state.isResting) return state;
    if (state.restSecondsRemaining <= 1) {
      return state.copyWith(isResting: false, restSecondsRemaining: 0);
    }
    return state.copyWith(restSecondsRemaining: state.restSecondsRemaining - 1);
  }

  SessionState skipRest(SessionState state) {
    return state.copyWith(isResting: false, restSecondsRemaining: 0);
  }
}
