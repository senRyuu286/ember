import 'package:drift/drift.dart';

class PlanDayTable extends Table {
  @override
  String get tableName => 'plan_days';

  TextColumn get id => text()();
  TextColumn get planId => text()();
  IntColumn get weekNumber => integer()();
  IntColumn get dayOfWeek => integer()(); // 1=Mon, 7=Sun
  BoolColumn get isRestDay =>
      boolean().withDefault(const Constant(false))();
  TextColumn get label => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}