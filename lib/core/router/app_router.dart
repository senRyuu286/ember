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

const _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.welcome,
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.checkEmail,
  AppRoutes.forgotPassword,
  AppRoutes.profileSetup,
};

// Public routes where an authenticated user should still be allowed to stay.
// Check email and profile setup are part of active flows that must complete
// before the user is sent to home, even if a session already exists.
const _allowAuthenticatedRoutes = {
  AppRoutes.checkEmail,
  AppRoutes.profileSetup,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _RouterRefreshNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final needsProfileSetup = ref.read(needsProfileSetupProvider);

      // Wait for the auth stream to emit before making any decision.
      if (authState.isLoading) return null;

      final currentPath = state.matchedLocation;

      // Splash handles its own navigation internally — never redirect away.
      if (currentPath == AppRoutes.splash) return null;

      // Active flows that must not be interrupted by the router.
      if (_allowAuthenticatedRoutes.contains(currentPath)) return null;

      // Signup flow takes priority over everything else.
      if (needsProfileSetup) return AppRoutes.profileSetup;

      final isAuthenticated = authState.asData?.value.session != null;
      final isOnPublicRoute = _publicRoutes.contains(currentPath);

      if (isAuthenticated && isOnPublicRoute) {
        // Signed-in user landed on a public route (e.g. welcome, sign-in
        // after a successful login) → send them to home.
        return AppRoutes.home;
      }

      if (!isAuthenticated && !isOnPublicRoute) {
        // Signed-out user trying to reach a protected route → welcome.
        return AppRoutes.welcome;
      }

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
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    ref.listen(needsProfileSetupProvider, (_, _) => notifyListeners());
  }
}