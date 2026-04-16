import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/local_db/app_database.dart';

import '../../data/profile_local_repository.dart';
import '../../data/profile_models.dart';
import '../../data/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileLocalRepositoryProvider = Provider<ProfileLocalRepository>((ref) {
  return ProfileLocalRepository(ref.watch(appDatabaseProvider));
});

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remote: ProfileRepository(ref.watch(supabaseProvider)),
    local: ref.watch(profileLocalRepositoryProvider),
  );
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return UpdateUserProfileUseCase(ref.watch(profileRepositoryProvider));
});

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    ref.watch(currentUserProvider);

    final getProfile = ref.read(getUserProfileUseCaseProvider);

    final cached = await getProfile.getCached();
    if (cached != null) {
      _syncFromRemote();
      return cached;
    }

    final fresh = await getProfile.sync();
    if (fresh != null) {
      await getProfile.upsertCache(fresh);
    }
    return fresh;
  }

  Future<void> _syncFromRemote() async {
    final getProfile = ref.read(getUserProfileUseCaseProvider);

    final fresh = await getProfile.sync();
    if (fresh == null) return;

    await getProfile.upsertCache(fresh);

    final current = state.asData?.value;
    if (current == null || _profilesDiffer(current, fresh)) {
      state = AsyncData(fresh);
    }
  }

  Future<void> updatePreference({
    String? avatarId,
    FitnessLevel? fitnessLevel,
    PrimaryGoal? primaryGoal,
    UnitSystem? unitSystem,
    int? defaultRestTimerSeconds,
    ThemePreference? theme,
    bool? notificationsEnabled,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final updated = current.copyWith(
      avatarId: avatarId,
      fitnessLevel: fitnessLevel,
      primaryGoal: primaryGoal,
      unitSystem: unitSystem,
      defaultRestTimerSeconds: defaultRestTimerSeconds,
      theme: theme,
      notificationsEnabled: notificationsEnabled,
    );

    state = AsyncData(updated);

    try {
      await ref.read(updateUserProfileUseCaseProvider).updatePreference(
            avatarId: avatarId,
            fitnessLevel: fitnessLevel,
            primaryGoal: primaryGoal,
            unitSystem: unitSystem,
            defaultRestTimerSeconds: defaultRestTimerSeconds,
            theme: theme,
            notificationsEnabled: notificationsEnabled,
          );
    } catch (_) {}
  }

  Future<void> saveEditableFields({
    required String bio,
    required FitnessLevel fitnessLevel,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final updated = current.copyWith(bio: bio, fitnessLevel: fitnessLevel);
    state = AsyncData(updated);

    try {
      await ref.read(updateUserProfileUseCaseProvider).saveEditableFields(
            bio: bio,
            fitnessLevel: fitnessLevel,
          );
    } catch (_) {}
  }

  bool _profilesDiffer(UserProfile a, UserProfile b) {
    return a.username != b.username ||
        a.bio != b.bio ||
        a.fitnessLevel != b.fitnessLevel ||
        a.streakCount != b.streakCount ||
        a.totalWorkoutsCompleted != b.totalWorkoutsCompleted ||
        a.emberXp != b.emberXp ||
        a.primaryGoal != b.primaryGoal ||
        a.unitSystem != b.unitSystem ||
        a.defaultRestTimerSeconds != b.defaultRestTimerSeconds ||
        a.theme != b.theme ||
        a.notificationsEnabled != b.notificationsEnabled;
  }
}
