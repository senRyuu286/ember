import 'package:drift/drift.dart';

class WeeklyBurnTable extends Table {
  @override
  String get tableName => 'weekly_burn';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get burnDate => text()(); // ISO8601 date string YYYY-MM-DD
  TextColumn get status => text()(); // 'workout_done' | 'rest_day'

  @override
  Set<Column> get primaryKey => {id};
}