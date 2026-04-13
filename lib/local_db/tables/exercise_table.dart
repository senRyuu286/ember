import 'package:drift/drift.dart';

class ExerciseTable extends Table {
  @override
  String get tableName => 'exercises';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant('strength'))();
  TextColumn get difficulty => text().nullable()();
  TextColumn get muscleGroups => text()(); // JSON array
  TextColumn get secondaryMuscles => text().withDefault(const Constant('[]'))();
  TextColumn get equipment => text().withDefault(const Constant('[]'))();
  TextColumn get instructions => text()();
  TextColumn get breathingCues => text().nullable()();
  TextColumn get dos => text().withDefault(const Constant('[]'))();
  TextColumn get donts => text().withDefault(const Constant('[]'))();
  IntColumn get xpReward => integer().withDefault(const Constant(0))();
  TextColumn get syncedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}