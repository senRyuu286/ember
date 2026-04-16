import '../../data/profile_models.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final IProfileRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<void> updatePreference({
    String? avatarId,
    FitnessLevel? fitnessLevel,
    PrimaryGoal? primaryGoal,
    UnitSystem? unitSystem,
    int? defaultRestTimerSeconds,
    ThemePreference? theme,
    bool? notificationsEnabled,
  }) async {
    await _repository.updateCachedPreference(
      avatarId: avatarId,
      fitnessLevel: fitnessLevel?.value,
      primaryGoal: primaryGoal?.value,
      unitSystem: unitSystem?.value,
      defaultRestTimerSeconds: defaultRestTimerSeconds,
      theme: theme?.value,
      notificationsEnabled: notificationsEnabled,
    );

    await _repository.updateRemoteProfile(
      avatarId: avatarId,
      fitnessLevel: fitnessLevel,
      primaryGoal: primaryGoal,
      unitSystem: unitSystem,
      defaultRestTimerSeconds: defaultRestTimerSeconds,
      theme: theme,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> saveEditableFields({
    required String bio,
    required FitnessLevel fitnessLevel,
  }) async {
    await _repository.updateCachedPreference(
      bio: bio,
      fitnessLevel: fitnessLevel.value,
    );

    await _repository.updateRemoteProfile(
      bio: bio,
      fitnessLevel: fitnessLevel,
    );
  }
}
