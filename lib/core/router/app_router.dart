import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/auth/ui/check_email_screen.dart';
import 'package:ember/features/auth/ui/forgot_password_screen.dart';
import 'package:ember/features/auth/ui/profile_setup_screen.dart';
import 'package:ember/features/auth/ui/sign_in_screen.dart';
import 'package:ember/features/auth/ui/sign_up_screen.dart';
import 'package:ember/features/branding/ui/splash_screen.dart';
import 'package:ember/features/branding/ui/welcome_screen.dart';
import 'package:ember/features/home/ui/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _RouterRefreshNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final needsProfileSetup = ref.read(needsProfileSetupProvider);

      if (authState.isLoading) return null;

      final currentPath = state.matchedLocation;

      final isOnSplash = currentPath == AppRoutes.splash;
      final isOnProfileSetup = currentPath == AppRoutes.profileSetup;
      final isOnCheckEmail = currentPath == AppRoutes.checkEmail;

      if (isOnSplash) return null;
      if (isOnProfileSetup) return null;
      if (isOnCheckEmail) return null;

      // In-memory flag set during the current signup flow
      if (needsProfileSetup) return AppRoutes.profileSetup;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkEmail,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return CheckEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(needsProfileSetupProvider, (_, __) => notifyListeners());
  }
}