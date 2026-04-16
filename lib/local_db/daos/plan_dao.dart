import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/workout_plan_table.dart';
import '../tables/plan_day_table.dart';
import '../tables/plan_day_routine_table.dart';
import '../tables/routine_table.dart';

part 'plan_dao.g.dart';

@DriftAccessor(tables: [
  WorkoutPlanTable,
  PlanDayTable,
  PlanDayRoutineTable,
  RoutineTable,
])
class PlanDao extends DatabaseAccessor<AppDatabase> with _$PlanDaoMixin {
  PlanDao(super.db);

  // ── Plans ─────────────────────────────────────────────────────────────────

  Future<List<WorkoutPlanTableData>> getAllPlans() {
    return select(workoutPlanTable).get();
  }

  Future<WorkoutPlanTableData?> getPlanById(String id) {
    return (select(workoutPlanTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<WorkoutPlanTableData?> getActivePlan() {
    return (select(workoutPlanTable)
          ..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();
  }

  Future<void> upsertPlans(List<WorkoutPlanTableCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(workoutPlanTable, rows);
    });
  }

  Future<void> upsertPlanWithDays({
    required WorkoutPlanTableCompanion plan,
    required List<PlanDayTableCompanion> days,
    required List<PlanDayRoutineTableCompanion> dayRoutines,
  }) async {
    await transaction(() async {
      await into(workoutPlanTable).insertOnConflictUpdate(plan);

      final oldDays = await (select(planDayTable)
            ..where((t) => t.planId.equals(plan.id.value)))
          .get();
      for (final day in oldDays) {
        await (delete(planDayRoutineTable)
              ..where((t) => t.planDayId.equals(day.id)))
            .go();
      }
      await (delete(planDayTable)
            ..where((t) => t.planId.equals(plan.id.value)))
          .go();

      if (days.isNotEmpty) {
        await batch((b) => b.insertAll(planDayTable, days));
      }
      if (dayRoutines.isNotEmpty) {
        await batch((b) => b.insertAll(planDayRoutineTable, dayRoutines));
      }
    });
  }

  Future<void> deletePlanById(String id) async {
    await transaction(() async {
      final days = await (select(planDayTable)
            ..where((t) => t.planId.equals(id)))
          .get();
      for (final day in days) {
        await (delete(planDayRoutineTable)
              ..where((t) => t.planDayId.equals(day.id)))
            .go();
      }
      await (delete(planDayTable)..where((t) => t.planId.equals(id))).go();
      await (delete(workoutPlanTable)..where((t) => t.id.equals(id))).go();
    });
  }

  // ── Plan days ─────────────────────────────────────────────────────────────

  Future<List<PlanDayTableData>> getDaysForPlan(String planId) {
    return (select(planDayTable)
          ..where((t) => t.planId.equals(planId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.weekNumber),
            (t) => OrderingTerm.asc(t.dayOfWeek),
          ]))
        .get();
  }

  // ── Plan day routines ─────────────────────────────────────────────────────

  Future<List<PlanDayRoutineTableData>> getRoutinesForDay(String planDayId) {
    return (select(planDayRoutineTable)
          ..where((t) => t.planDayId.equals(planDayId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  // ── Routine title lookup ──────────────────────────────────────────────────

  /// Looks up a routine title from the local routine cache.
  /// Returns null if the routine is not yet cached locally.
  Future<String?> getRoutineTitleById(String routineId) async {
    final row = await (select(routineTable)
          ..where((t) => t.id.equals(routineId)))
        .getSingleOrNull();
    return row?.title;
  }
}