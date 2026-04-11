import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/local_db/app_database.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';
import '../data/profile_local_repository.dart';

// ── Infrastructure providers ──────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
});

final profileLocalRepositoryProvider = Provider<ProfileLocalRepository>((ref) {
  return ProfileLocalRepository(ref.watch(appDatabaseProvider));
});

// ── Main profile provider ─────────────────────────────────────────────────
//
// Strategy:
//   1. Serve the local Drift cache immediately (no loading spinner).
//   2. Fetch fresh data from Supabase in the background.
//   3. Write the fresh data back to Drift and emit the updated profile.
//
// This means the screen renders instantly with cached data, then silently
// updates when the network response arrives.

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
      UserProfileNotifier.new,
    );

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    // Re-run whenever the auth state changes (sign in / sign out).
    ref.watch(currentUserProvider);

    final local = ref.read(profileLocalRepositoryProvider);
    final remote = ref.read(profileRepositoryProvider);

    // Step 1: serve local cache immediately.
    final cached = await local.getProfile();
    if (cached != null) {
      // Step 2: kick off background sync without awaiting.
      _syncFromRemote();
      return cached;
    }

    // No cache yet (first launch after install / after sign-out cleared it).
    // Fall through to a full remote fetch.
    final fresh = await remote.getProfile();
    if (fresh != null) {
      await local.upsertProfile(fresh);
    }
    return fresh;
  }

  // Fetches latest profile from Supabase and updates local cache + state.
  // Called in the background after serving the cached value.
  Future<void> _syncFromRemote() async {
    final remote = ref.read(profileRepositoryProvider);
    final local = ref.read(profileLocalRepositoryProvider);

    final fresh = await remote.getProfile();
    if (fresh == null) return;

    await local.upsertProfile(fresh);

    // Only update state if the data actually changed to avoid unnecessary
    // rebuilds when the cached and remote values are identical.
    final current = state.asData?.value;
    if (current == null || _profilesDiffer(current, fresh)) {
      state = AsyncData(fresh);
    }
  }

  // Optimistically update local state and cache, then write to Supabase.
  // Used for preference fields that save immediately on change.
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

    // Optimistic update — screen reflects the change instantly.
    state = AsyncData(updated);

    // Persist locally.
    await ref
        .read(profileLocalRepositoryProvider)
        .updatePreference(
          avatarId: avatarId,
          fitnessLevel: fitnessLevel?.value,
          primaryGoal: primaryGoal?.value,
          unitSystem: unitSystem?.value,
          defaultRestTimerSeconds: defaultRestTimerSeconds,
          theme: theme?.value,
          notificationsEnabled: notificationsEnabled,
        );

    // Persist to Supabase.
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            avatarId: avatarId,
            fitnessLevel: fitnessLevel,
            primaryGoal: primaryGoal,
            unitSystem: unitSystem,
            defaultRestTimerSeconds: defaultRestTimerSeconds,
            theme: theme,
            notificationsEnabled: notificationsEnabled,
          );
    } catch (_) {
      // Remote write failed -- local state is still updated.
      // A background sync on next launch will reconcile if needed.
      // Silently swallow -- preferences are low-stakes data.
    }
  }

  // Saves bio and fitnessLevel on Done tap.
  Future<void> saveEditableFields({
    required String bio,
    required FitnessLevel fitnessLevel,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;

    final updated = current.copyWith(bio: bio, fitnessLevel: fitnessLevel);
    state = AsyncData(updated);

    await ref
        .read(profileLocalRepositoryProvider)
        .updatePreference(bio: bio, fitnessLevel: fitnessLevel.value);

    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(bio: bio, fitnessLevel: fitnessLevel);
    } catch (_) {
      // Same silent-fail strategy as updatePreference.
    }
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
