import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

final supabaseProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value.session?.user;
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(ref.watch(authRepositoryProvider));
});

final saveProfileSetupUseCaseProvider = Provider<SaveProfileSetupUseCase>((ref) {
  return SaveProfileSetupUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentProfileUseCaseProvider = Provider<GetCurrentProfileUseCase>((ref) {
  return GetCurrentProfileUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

class NeedsProfileSetupNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setNeeded() => state = true;
  void setComplete() => state = false;
}

class SignUpNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(signUpUseCaseProvider).execute(
            email: email,
            password: password,
          );
      ref.read(needsProfileSetupProvider.notifier).setNeeded();
    });
  }
}

class SignInNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async => null;

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(signInUseCaseProvider).execute(
            email: email,
            password: password,
          );
    });

    return state.asData?.value;
  }
}

class ForgotPasswordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendResetEmail({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(forgotPasswordUseCaseProvider).execute(email: email);
    });
  }
}

class ProfileSetupNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveProfile({
    required String username,
    required String avatarId,
    String? bio,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(saveProfileSetupUseCaseProvider).execute(
            username: username,
            avatarId: avatarId,
            bio: bio,
          );
      ref.invalidate(currentProfileProvider);
    });
  }
}

class SignOutNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(signOutUseCaseProvider).execute();
    });
  }
}

final needsProfileSetupProvider =
    NotifierProvider<NeedsProfileSetupNotifier, bool>(
  NeedsProfileSetupNotifier.new,
);

final currentProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(getCurrentProfileUseCaseProvider).execute();
});
