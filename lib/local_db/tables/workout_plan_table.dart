import 'package:drift/drift.dart';

class WorkoutPlanTable extends Table {
  @override
  String get tableName => 'workout_plans';

  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isBuiltIn =>
      boolean().withDefault(const Constant(false))();
  IntColumn get totalWeeks => integer().withDefault(const Constant(1))();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false))();
  TextColumn get startedAt => text().nullable()();
  TextColumn get createdAt => text().withDefault(const Constant(''))();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}