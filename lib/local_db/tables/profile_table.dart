import 'package:drift/drift.dart';

class ProfileTable extends Table {
  @override
  String get tableName => 'profile';

  TextColumn get id => text()();
  TextColumn get username => text().nullable()();
  TextColumn get avatarId => text().withDefault(const Constant('1'))();
  TextColumn get bio => text().nullable()();
  TextColumn get fitnessLevel =>
      text().withDefault(const Constant('beginner'))();
  IntColumn get streakCount => integer().withDefault(const Constant(0))();
  IntColumn get totalWorkoutsCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get emberXp => integer().withDefault(const Constant(0))();
  TextColumn get primaryGoal =>
      text().withDefault(const Constant('generalFitness'))();
  TextColumn get unitSystem =>
      text().withDefault(const Constant('lbs_mi'))();
  IntColumn get defaultRestTimerSeconds =>
      integer().withDefault(const Constant(60))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();

  // Empty string default so existing rows migrated from schema v2
  // do not fail to read. profile_local_repository handles the empty
  // string by falling back to DateTime(2025, 1, 1).
  TextColumn get createdAt =>
      text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}