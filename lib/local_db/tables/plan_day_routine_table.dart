import 'package:drift/drift.dart';

class PlanDayRoutineTable extends Table {
  @override
  String get tableName => 'plan_day_routines';

  TextColumn get id => text()();
  TextColumn get planDayId => text()();
  TextColumn get routineId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}