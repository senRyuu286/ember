import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_models.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<UserProfile?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromMap(response);
  }

  Future<void> updateProfile({
    String? username,
    String? avatarId,
    String? bio,
    FitnessLevel? fitnessLevel,
    PrimaryGoal? primaryGoal,
    UnitSystem? unitSystem,
    int? defaultRestTimerSeconds,
    ThemePreference? theme,
    bool? notificationsEnabled,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user found.');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (username != null) updates['username'] = username;
    if (avatarId != null) updates['avatar_id'] = avatarId;
    if (bio != null) updates['bio'] = bio;
    if (fitnessLevel != null) updates['fitness_level'] = fitnessLevel.value;
    if (primaryGoal != null) updates['primary_goal'] = primaryGoal.value;
    if (unitSystem != null) updates['unit_system'] = unitSystem.value;
    if (defaultRestTimerSeconds != null) {
      updates['default_rest_timer_seconds'] = defaultRestTimerSeconds;
    }
    if (theme != null) updates['theme'] = theme.value;
    if (notificationsEnabled != null) {
      updates['notifications_enabled'] = notificationsEnabled;
    }

    await _client.from('profiles').update(updates).eq('id', userId);
  }
}