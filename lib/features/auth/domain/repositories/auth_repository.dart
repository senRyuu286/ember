import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();

  Future<void> saveProfile({
    required String username,
    required String avatarId,
    String? bio,
  });

  Future<Map<String, dynamic>?> getProfile();
  Future<Map<String, dynamic>?> getProfileByUserId(String userId);
}
