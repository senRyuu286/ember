import 'package:drift/drift.dart';

class RoutineTable extends Table {
  @override
  String get tableName => 'routines';

  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isBuiltIn =>
      boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text().withDefault(const Constant(''))();
  TextColumn get updatedAt => text().withDefault(const Constant(''))();
  TextColumn get lastPerformedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}