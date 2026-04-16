import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/profile_table.dart';
import 'tables/workout_session_table.dart';
import 'tables/weekly_burn_table.dart';
import 'tables/exercise_table.dart';
import 'tables/routine_table.dart';
import 'tables/routine_exercise_table.dart';
import 'tables/workout_plan_table.dart';
import 'tables/plan_day_table.dart';
import 'tables/plan_day_routine_table.dart';
import 'daos/routine_dao.dart';
import 'daos/plan_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ProfileTable,
    WorkoutSessionTable,
    WeeklyBurnTable,
    ExerciseTable,
    RoutineTable,
    RoutineExerciseTable,
    WorkoutPlanTable,
    PlanDayTable,
    PlanDayRoutineTable,
  ],
  daos: [
    RoutineDao,
    PlanDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(workoutSessionTable);
            await migrator.createTable(weeklyBurnTable);
          }
          if (from < 3) {
            await migrator.addColumn(profileTable, profileTable.createdAt);
          }
          if (from < 4) {
            await migrator.createTable(exerciseTable);
          }
          if (from < 5) {
            await migrator.createTable(routineTable);
            await migrator.createTable(routineExerciseTable);
          }
          if (from < 6) {
            await migrator.addColumn(
                routineTable, routineTable.lastPerformedAt);
          }
          if (from < 7) {
            await migrator.createTable(workoutPlanTable);
            await migrator.createTable(planDayTable);
            await migrator.createTable(planDayRoutineTable);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ember.db'));
    return NativeDatabase.createInBackground(file);
  });
}