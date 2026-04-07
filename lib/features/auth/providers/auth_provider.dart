import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

final supabaseProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  // Watch authStateProvider so this re-evaluates on every auth change
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value.session?.user;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

// Tracks whether the current session needs profile setup
final needsProfileSetupProvider =
    NotifierProvider<NeedsProfileSetupNotifier, bool>(
        NeedsProfileSetupNotifier.new);

class NeedsProfileSetupNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setNeeded() => state = true;
  void setComplete() => state = false;
}

// Sign up
final signUpNotifierProvider =
    AsyncNotifierProvider<SignUpNotifier, void>(SignUpNotifier.new);

class SignUpNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
          );
      ref.read(needsProfileSetupProvider.notifier).setNeeded();
    });
  }
}

// Sign in
final signInNotifierProvider =
    AsyncNotifierProvider<SignInNotifier, AuthResponse?>(SignInNotifier.new);

class SignInNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async => null;

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          );
    });

    return state.asData?.value;
  }
}

// Forgot password
final forgotPasswordNotifierProvider =
    AsyncNotifierProvider<ForgotPasswordNotifier, void>(
        ForgotPasswordNotifier.new);

class ForgotPasswordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendResetEmail({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(
            email: email,
          );
    });
  }
}

// Profile setup
final profileSetupNotifierProvider =
    AsyncNotifierProvider<ProfileSetupNotifier, void>(
        ProfileSetupNotifier.new);

class ProfileSetupNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveProfile({
    required String username,
    required String avatarId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).saveProfile(
            username: username,
            avatarId: avatarId,
          );
      // Invalidate so the router re-fetches the now-complete profile
      ref.invalidate(currentProfileProvider);
    });
  }
}

// Fetches the current user's profile from Supabase.
// Automatically re-fetches when currentUserProvider changes
// because it watches it — meaning every sign in, sign out,
// or session restore triggers a fresh fetch.
final currentProfileProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return await ref.read(authRepositoryProvider).getProfile();
});