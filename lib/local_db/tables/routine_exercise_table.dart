import 'package:drift/drift.dart';

class RoutineExerciseTable extends Table {
  @override
  String get tableName => 'routine_exercises';

  TextColumn get id => text()();
  TextColumn get routineId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetReps => integer().withDefault(const Constant(10))();
  RealColumn get targetWeight => real().nullable()();
  TextColumn get targetWeightUnit =>
      text().withDefault(const Constant('lbs'))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}