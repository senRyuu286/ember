import 'package:drift/drift.dart';

class WorkoutSessionTable extends Table {
  @override
  String get tableName => 'workout_sessions';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get routineId => text().nullable()();
  TextColumn get routineName => text().nullable()();
  RealColumn get totalVolumeLbs => real().withDefault(const Constant(0.0))();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get startedAt => text()();
  TextColumn get endedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}