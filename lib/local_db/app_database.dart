import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/profile_table.dart';
import 'tables/workout_session_table.dart';
import 'tables/weekly_burn_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ProfileTable, WorkoutSessionTable, WeeklyBurnTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(workoutSessionTable);
            await migrator.createTable(weeklyBurnTable);
          }
          if (from < 3) {
            await migrator.addColumn(
              profileTable,
              profileTable.createdAt,
            );
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