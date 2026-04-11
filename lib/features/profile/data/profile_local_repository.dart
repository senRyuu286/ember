import 'package:ember/local_db/app_database.dart';
import 'package:drift/drift.dart';
import 'profile_models.dart';

class ProfileLocalRepository {
  final AppDatabase _db;

  ProfileLocalRepository(this._db);

  Future<UserProfile?> getProfile() async {
    final row = await (_db.select(_db.profileTable)..limit(1)).getSingleOrNull();
    if (row == null) return null;
    return _rowToProfile(row);
  }

  Future<void> upsertProfile(UserProfile profile) async {
    await _db.into(_db.profileTable).insertOnConflictUpdate(
          ProfileTableCompanion(
            id: Value(profile.id),
            username: Value(profile.username),
            avatarId: Value(profile.avatarId),
            bio: Value(profile.bio),
            fitnessLevel: Value(profile.fitnessLevel.value),
            streakCount: Value(profile.streakCount),
            totalWorkoutsCompleted: Value(profile.totalWorkoutsCompleted),
            emberXp: Value(profile.emberXp),
            primaryGoal: Value(profile.primaryGoal.value),
            unitSystem: Value(profile.unitSystem.value),
            defaultRestTimerSeconds: Value(profile.defaultRestTimerSeconds),
            theme: Value(profile.theme.value),
            notificationsEnabled: Value(profile.notificationsEnabled),
          ),
        );
  }

  Future<void> updatePreference({
    String? avatarId,
    String? unitSystem,
    String? theme,
    int? defaultRestTimerSeconds,
    bool? notificationsEnabled,
    String? primaryGoal,
    String? fitnessLevel,
    String? bio,
  }) async {
    final companion = ProfileTableCompanion(
      avatarId: avatarId != null ? Value(avatarId) : const Value.absent(),
      unitSystem:
          unitSystem != null ? Value(unitSystem) : const Value.absent(),
      theme: theme != null ? Value(theme) : const Value.absent(),
      defaultRestTimerSeconds: defaultRestTimerSeconds != null
          ? Value(defaultRestTimerSeconds)
          : const Value.absent(),
      notificationsEnabled: notificationsEnabled != null
          ? Value(notificationsEnabled)
          : const Value.absent(),
      primaryGoal:
          primaryGoal != null ? Value(primaryGoal) : const Value.absent(),
      fitnessLevel:
          fitnessLevel != null ? Value(fitnessLevel) : const Value.absent(),
      bio: bio != null ? Value(bio) : const Value.absent(),
    );

    await (_db.update(_db.profileTable)).write(companion);
  }

  Future<void> clearProfile() async {
    await _db.delete(_db.profileTable).go();
  }

  UserProfile _rowToProfile(ProfileTableData row) {
    return UserProfile(
      id: row.id,
      username: row.username,
      avatarId: row.avatarId,
      bio: row.bio,
      fitnessLevel: FitnessLevel.fromValue(row.fitnessLevel),
      streakCount: row.streakCount,
      totalWorkoutsCompleted: row.totalWorkoutsCompleted,
      emberXp: row.emberXp,
      primaryGoal: PrimaryGoal.fromValue(row.primaryGoal),
      unitSystem: UnitSystem.fromValue(row.unitSystem),
      defaultRestTimerSeconds: row.defaultRestTimerSeconds,
      theme: ThemePreference.fromValue(row.theme),
      notificationsEnabled: row.notificationsEnabled,
    );
  }
}