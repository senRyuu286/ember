import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/routine_table.dart';
import '../tables/routine_exercise_table.dart';
import '../tables/exercise_table.dart';

part 'routine_dao.g.dart';

@DriftAccessor(tables: [RoutineTable, RoutineExerciseTable, ExerciseTable])
class RoutineDao extends DatabaseAccessor<AppDatabase>
    with _$RoutineDaoMixin {
  RoutineDao(super.db);

  // ── Routine summaries ─────────────────────────────────────────────────────

  Future<List<RoutineTableData>> getAllRoutineSummaries() {
    return select(routineTable).get();
  }

  Future<void> upsertRoutineSummaries(
      List<RoutineTableCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(routineTable, rows);
    });
  }

  // ── Routine detail ────────────────────────────────────────────────────────

  Future<RoutineTableData?> getRoutineById(String id) {
    return (select(routineTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<RoutineExerciseTableData>> getExercisesForRoutine(
      String routineId) {
    return (select(routineExerciseTable)
          ..where((t) => t.routineId.equals(routineId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<ExerciseTableData?> getExerciseById(String id) async {
    final query = select(exerciseTable)
      ..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result;
  }

  Future<void> upsertRoutineWithExercises({
    required RoutineTableCompanion routine,
    required List<RoutineExerciseTableCompanion> exercises,
  }) async {
    await transaction(() async {
      await into(routineTable).insertOnConflictUpdate(routine);
      await (delete(routineExerciseTable)
            ..where((t) => t.routineId.equals(routine.id.value)))
          .go();
      if (exercises.isNotEmpty) {
        await batch((b) {
          b.insertAll(routineExerciseTable, exercises);
        });
      }
    });
  }

  Future<void> deleteRoutineById(String id) async {
    await transaction(() async {
      await (delete(routineExerciseTable)
            ..where((t) => t.routineId.equals(id)))
          .go();
      await (delete(routineTable)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> updateLastPerformed(String id, DateTime at) {
    return (update(routineTable)..where((t) => t.id.equals(id))).write(
      RoutineTableCompanion(
        lastPerformedAt: Value(at.toIso8601String()),
      ),
    );
  }
}