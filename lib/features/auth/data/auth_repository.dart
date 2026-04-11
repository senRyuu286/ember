import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.ember://login-callback/',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> saveProfile({
    required String username,
    required String avatarId,
    String? bio,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user found.');

    final updates = <String, dynamic>{
      'username': username,
      'avatar_id': avatarId,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (bio != null && bio.isNotEmpty) {
      updates['bio'] = bio;
    }

    await _client.from('profiles').update(updates).eq('id', userId);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    return await getProfileByUserId(userId);
  }

  Future<Map<String, dynamic>?> getProfileByUserId(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }
}