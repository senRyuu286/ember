import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:ember/local_db/app_database.dart';
import 'exercise_models.dart';

class ExerciseLocalRepository {
  final AppDatabase _db;

  ExerciseLocalRepository(this._db);

  Future<List<Exercise>> getAllExercises() async {
    final rows = await (_db.select(_db.exerciseTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(_rowToExercise).toList();
  }

  Future<bool> hasExercises() async {
    final count = await _db.exerciseTable.count().getSingle();
    return count > 0;
  }

  Future<void> upsertExercises(List<Exercise> exercises) async {
    for (final e in exercises) {
      await _db.into(_db.exerciseTable).insertOnConflictUpdate(
            ExerciseTableCompanion(
              id: Value(e.id),
              name: Value(e.name),
              category: Value(e.category.name),
              difficulty: Value(e.difficulty?.name),
              muscleGroups: Value(jsonEncode(e.muscleGroups)),
              secondaryMuscles: Value(jsonEncode(e.secondaryMuscles)),
              equipment: Value(jsonEncode(e.equipment)),
              instructions: Value(e.instructions),
              breathingCues: Value(e.breathingCues),
              dos: Value(jsonEncode(e.dos)),
              donts: Value(jsonEncode(e.donts)),
              xpReward: Value(e.xpReward),
              syncedAt: Value(DateTime.now().toIso8601String()),
            ),
          );
    }
  }

  Exercise _rowToExercise(ExerciseTableData row) {
    List<String> decode(String json) {
      try {
        return (jsonDecode(json) as List).cast<String>();
      } catch (_) {
        return [];
      }
    }

    return Exercise(
      id: row.id,
      name: row.name,
      category: ExerciseCategory.fromValue(row.category),
      difficulty: ExerciseDifficulty.fromValue(row.difficulty),
      muscleGroups: decode(row.muscleGroups),
      secondaryMuscles: decode(row.secondaryMuscles),
      equipment: decode(row.equipment),
      instructions: row.instructions,
      breathingCues: row.breathingCues,
      dos: decode(row.dos),
      donts: decode(row.donts),
      xpReward: row.xpReward,
    );
  }
}