import 'package:ember/features/exercises/data/exercise_models.dart';

class RoutineExercise {
  final String id;
  final String routineId;
  final String exerciseId;
  final int sortOrder;
  final int targetSets;
  final int targetReps;
  final double? targetWeight;
  final String targetWeightUnit;
  final String? notes;
  final Exercise? exercise;

  const RoutineExercise({
    required this.id,
    required this.routineId,
    required this.exerciseId,
    required this.sortOrder,
    required this.targetSets,
    required this.targetReps,
    required this.targetWeight,
    required this.targetWeightUnit,
    required this.notes,
    this.exercise,
  });

  RoutineExercise copyWith({
    int? sortOrder,
    int? targetSets,
    int? targetReps,
    double? targetWeight,
    String? targetWeightUnit,
    String? notes,
    bool clearWeight = false,
  }) {
    return RoutineExercise(
      id: id,
      routineId: routineId,
      exerciseId: exerciseId,
      sortOrder: sortOrder ?? this.sortOrder,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: clearWeight ? null : (targetWeight ?? this.targetWeight),
      targetWeightUnit: targetWeightUnit ?? this.targetWeightUnit,
      notes: notes ?? this.notes,
      exercise: exercise,
    );
  }

  factory RoutineExercise.fromMap(
    Map<String, dynamic> map, {
    Exercise? exercise,
  }) {
    return RoutineExercise(
      id: map['id'] as String,
      routineId: map['routine_id'] as String,
      exerciseId: map['exercise_id'] as String,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      targetSets: (map['target_sets'] as int?) ?? 3,
      targetReps: (map['target_reps'] as int?) ?? 10,
      targetWeight: (map['target_weight'] as num?)?.toDouble(),
      targetWeightUnit: (map['target_weight_unit'] as String?) ?? 'lbs',
      notes: map['notes'] as String?,
      exercise: exercise,
    );
  }
}

class Routine {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final bool isBuiltIn;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<RoutineExercise> exercises;
  final DateTime? lastPerformedAt;

  const Routine({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isBuiltIn,
    required this.createdAt,
    required this.updatedAt,
    required this.exercises,
    this.lastPerformedAt,
  });

  bool get isOwned => !isBuiltIn && userId != null;

  int estimatedDurationSeconds(int restTimerSeconds) {
    const int strengthSecsPerRep = 4;
    const int stretchSecsPerRep = 10;
    const int cardioSecsPerRep = 3;

    int total = 0;
    for (final re in exercises) {
      final ex = re.exercise;
      int secsPerRep = strengthSecsPerRep;
      if (ex != null) {
        if (ex.category == ExerciseCategory.stretch) {
          secsPerRep = stretchSecsPerRep;
        } else if (ex.category == ExerciseCategory.cardio) {
          secsPerRep = cardioSecsPerRep;
        }
      }
      total +=
          (re.targetReps * secsPerRep + restTimerSeconds) * re.targetSets;
    }
    return total;
  }

  String formattedDuration(int restTimerSeconds) {
    final secs = estimatedDurationSeconds(restTimerSeconds);
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '~${h}h ${m}m';
    return '~${m}m';
  }

  factory Routine.fromMap(
    Map<String, dynamic> map, {
    List<RoutineExercise> exercises = const [],
    DateTime? lastPerformedAt,
  }) {
    return Routine(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      isBuiltIn: (map['is_built_in'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      exercises: exercises,
      lastPerformedAt: lastPerformedAt,
    );
  }
}

/// Lightweight summary used in the routines list. No exercises loaded.
class RoutineSummary {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final bool isBuiltIn;
  final int exerciseCount;
  final int totalSets;
  final DateTime? lastPerformedAt;

  const RoutineSummary({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.isBuiltIn,
    required this.exerciseCount,
    required this.totalSets,
    this.lastPerformedAt,
  });

  bool get isOwned => !isBuiltIn && userId != null;

  /// Rough duration estimate: avg 4 sec/rep + restTimerSeconds per set.
  String formattedDuration(int restTimerSeconds) {
    const int secsPerRep = 4;
    final secs = totalSets * (10 * secsPerRep + restTimerSeconds);
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '~${h}h ${m}m';
    if (m == 0) return '~1m';
    return '~${m}m';
  }
}