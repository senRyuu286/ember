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

  @override
  Set<Column> get primaryKey => {id};
}