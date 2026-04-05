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
  return ref.watch(supabaseProvider).auth.currentUser;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

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
    AsyncNotifierProvider<SignInNotifier, void>(SignInNotifier.new);

class SignInNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          );
    });
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