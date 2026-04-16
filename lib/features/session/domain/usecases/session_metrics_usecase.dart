import '../entities/session_entities.dart';

class SessionMetricsUseCase {
  List<CompletedSetLog> collectCompletedSetLogs(SessionState state) {
    final result = <CompletedSetLog>[];

    for (final entry in state.setLogs.entries) {
      for (final log in entry.value.where((l) => l.isCompleted)) {
        result.add(
          CompletedSetLog(
            exerciseId: entry.key,
            setNumber: log.setNumber,
            reps: log.reps,
            weight: log.weight,
            unit: state.routine.exercises
                .firstWhere(
                  (e) => e.exerciseId == entry.key,
                  orElse: () => state.routine.exercises.first,
                )
                .targetWeightUnit,
            completedAt: DateTime.now(),
          ),
        );
      }
    }

    return result;
  }

  double totalVolumeLbs(SessionState state) {
    double total = 0;

    for (final entry in state.setLogs.entries) {
      for (final log in entry.value.where((l) => l.isCompleted)) {
        if (log.weight != null && log.reps != null) {
          final ex = state.routine.exercises.firstWhere(
            (e) => e.exerciseId == entry.key,
            orElse: () => state.routine.exercises.first,
          );
          final weightLbs = ex.targetWeightUnit == 'kg' ? (log.weight! * 2.20462) : log.weight!;
          total += weightLbs * log.reps!;
        }
      }
    }

    return total;
  }

  WorkoutSummary buildSummary(SessionState state, int durationSeconds) {
    final exerciseSummaries = <ExerciseSummary>[];

    for (final ex in state.routine.exercises) {
      final logs =
          (state.setLogs[ex.exerciseId] ?? []).where((l) => l.isCompleted).toList();
      if (logs.isEmpty) continue;

      final totalReps = logs.fold<int>(0, (sum, l) => sum + (l.reps ?? 0));
      double? totalWeight;

      if (logs.any((l) => l.weight != null)) {
        totalWeight = logs.fold<double>(0, (sum, l) {
          if (l.weight == null || l.reps == null) return sum;
          final w = ex.targetWeightUnit == 'kg' ? l.weight! * 2.20462 : l.weight!;
          return sum + w * l.reps!;
        });
      }

      exerciseSummaries.add(
        ExerciseSummary(
          exerciseName: ex.exercise?.name ?? ex.exerciseId,
          setsCompleted: logs.length,
          totalReps: totalReps,
          totalWeightLbs: totalWeight,
          weightUnit: ex.targetWeightUnit,
        ),
      );
    }

    return WorkoutSummary(
      routineTitle: state.routine.title,
      durationSeconds: durationSeconds,
      totalSetsCompleted: state.completedSetsCount,
      totalVolumeLbs: totalVolumeLbs(state),
      exercises: exerciseSummaries,
    );
  }
}
