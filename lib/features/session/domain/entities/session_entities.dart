import 'package:ember/features/workouts/data/workout_models.dart';

class ExerciseSummary {
  final String exerciseName;
  final int setsCompleted;
  final int totalReps;
  final double? totalWeightLbs;
  final String weightUnit;

  const ExerciseSummary({
    required this.exerciseName,
    required this.setsCompleted,
    required this.totalReps,
    required this.totalWeightLbs,
    required this.weightUnit,
  });
}

class WorkoutSummary {
  final String routineTitle;
  final int durationSeconds;
  final int totalSetsCompleted;
  final double totalVolumeLbs;
  final List<ExerciseSummary> exercises;

  const WorkoutSummary({
    required this.routineTitle,
    required this.durationSeconds,
    required this.totalSetsCompleted,
    required this.totalVolumeLbs,
    required this.exercises,
  });

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) {
      return '${h}h ${m}m ${s}s';
    }
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

class SetLog {
  final String exerciseId;
  final int setNumber;
  final int? reps;
  final double? weight;
  final bool isCompleted;

  const SetLog({
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.isCompleted = false,
  });

  SetLog copyWith({int? reps, double? weight, bool? isCompleted}) {
    return SetLog(
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class CompletedSetLog {
  final String exerciseId;
  final int setNumber;
  final int? reps;
  final double? weight;
  final String unit;
  final DateTime completedAt;

  const CompletedSetLog({
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.unit,
    required this.completedAt,
  });
}

class SessionState {
  final String sessionId;
  final Routine routine;
  final int currentExerciseIndex;
  final int currentSetIndex;
  final Map<String, List<SetLog>> setLogs;
  final DateTime startedAt;
  final bool isResting;
  final int restSecondsRemaining;
  final bool isFinished;

  const SessionState({
    required this.sessionId,
    required this.routine,
    required this.currentExerciseIndex,
    required this.currentSetIndex,
    required this.setLogs,
    required this.startedAt,
    this.isResting = false,
    this.restSecondsRemaining = 0,
    this.isFinished = false,
  });

  RoutineExercise get currentExercise => routine.exercises[currentExerciseIndex];

  RoutineExercise? get nextExercise {
    if (currentSetIndex < currentExercise.targetSets - 1) return null;
    final nextIdx = currentExerciseIndex + 1;
    if (nextIdx < routine.exercises.length) {
      return routine.exercises[nextIdx];
    }
    return null;
  }

  bool get isLastExercise => currentExerciseIndex == routine.exercises.length - 1;
  bool get isLastSet => currentSetIndex == currentExercise.targetSets - 1;

  int get completedSetsCount {
    int count = 0;
    for (final logs in setLogs.values) {
      count += logs.where((s) => s.isCompleted).length;
    }
    return count;
  }

  int get totalSetsCount => routine.exercises.fold(0, (sum, e) => sum + e.targetSets);

  int get completedExercisesCount => setLogs.entries.where((entry) {
        final ex = routine.exercises.firstWhere(
          (e) => e.exerciseId == entry.key,
          orElse: () => routine.exercises.first,
        );
        return entry.value.where((s) => s.isCompleted).length >= ex.targetSets;
      }).length;

  SessionState copyWith({
    int? currentExerciseIndex,
    int? currentSetIndex,
    Map<String, List<SetLog>>? setLogs,
    bool? isResting,
    int? restSecondsRemaining,
    bool? isFinished,
  }) {
    return SessionState(
      sessionId: sessionId,
      routine: routine,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      setLogs: setLogs ?? this.setLogs,
      startedAt: startedAt,
      isResting: isResting ?? this.isResting,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
