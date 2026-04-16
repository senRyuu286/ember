import '../../data/profile_models.dart';

abstract class IProfileRepository {
  Future<UserProfile?> getCachedProfile();
  Future<UserProfile?> getRemoteProfile();
  Future<void> upsertCachedProfile(UserProfile profile);

  Future<void> updateCachedPreference({
    String? avatarId,
    String? unitSystem,
    String? theme,
    int? defaultRestTimerSeconds,
    bool? notificationsEnabled,
    String? primaryGoal,
    String? fitnessLevel,
    String? bio,
  });

  Future<void> updateRemoteProfile({
    String? username,
    String? avatarId,
    String? bio,
    FitnessLevel? fitnessLevel,
    PrimaryGoal? primaryGoal,
    UnitSystem? unitSystem,
    int? defaultRestTimerSeconds,
    ThemePreference? theme,
    bool? notificationsEnabled,
  });

  Future<void> clearCachedProfile();
}
