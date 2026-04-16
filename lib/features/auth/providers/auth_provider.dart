import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/controllers/auth_controller.dart' as controller;

final supabaseProvider = controller.supabaseProvider;

final authStateProvider = controller.authStateProvider;

final currentUserProvider = controller.currentUserProvider;

final authRepositoryProvider = controller.authRepositoryProvider;

final needsProfileSetupProvider = controller.needsProfileSetupProvider;

final signUpNotifierProvider =
    AsyncNotifierProvider<controller.SignUpNotifier, void>(
  controller.SignUpNotifier.new,
);

final signInNotifierProvider =
    AsyncNotifierProvider<controller.SignInNotifier, AuthResponse?>(
  controller.SignInNotifier.new,
);

final forgotPasswordNotifierProvider =
    AsyncNotifierProvider<controller.ForgotPasswordNotifier, void>(
  controller.ForgotPasswordNotifier.new,
);

final profileSetupNotifierProvider =
    AsyncNotifierProvider<controller.ProfileSetupNotifier, void>(
  controller.ProfileSetupNotifier.new,
);

final currentProfileProvider = controller.currentProfileProvider;

final signOutNotifierProvider =
    AsyncNotifierProvider<controller.SignOutNotifier, void>(
  controller.SignOutNotifier.new,
);