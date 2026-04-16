import '../../domain/repositories/profile_repository.dart';
import '../profile_local_repository.dart';
import '../profile_models.dart';
import '../profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRepository _remote;
  final ProfileLocalRepository _local;

  ProfileRepositoryImpl({
    required ProfileRepository remote,
    required ProfileLocalRepository local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<UserProfile?> getCachedProfile() {
    return _local.getProfile();
  }

  @override
  Future<UserProfile?> getRemoteProfile() {
    return _remote.getProfile();
  }

  @override
  Future<void> upsertCachedProfile(UserProfile profile) {
    return _local.upsertProfile(profile);
  }

  @override
  Future<void> updateCachedPreference({
    String? avatarId,
    String? unitSystem,
    String? theme,
    int? defaultRestTimerSeconds,
    bool? notificationsEnabled,
    String? primaryGoal,
    String? fitnessLevel,
    String? bio,
  }) {
    return _local.updatePreference(
      avatarId: avatarId,
      unitSystem: unitSystem,
      theme: theme,
      defaultRestTimerSeconds: defaultRestTimerSeconds,
      notificationsEnabled: notificationsEnabled,
      primaryGoal: primaryGoal,
      fitnessLevel: fitnessLevel,
      bio: bio,
    );
  }

  @override
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
  }) {
    return _remote.updateProfile(
      username: username,
      avatarId: avatarId,
      bio: bio,
      fitnessLevel: fitnessLevel,
      primaryGoal: primaryGoal,
      unitSystem: unitSystem,
      defaultRestTimerSeconds: defaultRestTimerSeconds,
      theme: theme,
      notificationsEnabled: notificationsEnabled,
    );
  }

  @override
  Future<void> clearCachedProfile() {
    return _local.clearProfile();
  }
}
