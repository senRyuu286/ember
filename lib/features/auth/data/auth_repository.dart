import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.ember://login-callback/',
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
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

  @override
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    return await getProfileByUserId(userId);
  }

  @override
  Future<Map<String, dynamic>?> getProfileByUserId(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }
}