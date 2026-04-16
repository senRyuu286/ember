import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/auth/ui/check_email_screen.dart';
import 'package:ember/features/auth/ui/forgot_password_screen.dart';
import 'package:ember/features/auth/ui/profile_setup_screen.dart';
import 'package:ember/features/auth/ui/sign_in_screen.dart';
import 'package:ember/features/auth/ui/sign_up_screen.dart';
import 'package:ember/features/branding/ui/splash_screen.dart';
import 'package:ember/features/branding/ui/welcome_screen.dart';
import 'package:ember/features/home/ui/home_screen.dart';
import 'package:ember/features/legal/ui/terms_screen.dart';
import 'package:ember/features/legal/ui/privacy_screen.dart';
import 'package:ember/features/legal/ui/changelog_screen.dart';
import 'package:ember/features/legal/ui/help_screen.dart';
import 'package:ember/features/workouts/data/workout_models.dart';
import 'package:ember/features/workouts/data/plan_models.dart';
import 'package:ember/features/workouts/ui/routine_detail_screen.dart';
import 'package:ember/features/workouts/ui/create_edit_routine_screen.dart';
import 'package:ember/features/session/data/models/session_models.dart';
import 'package:ember/features/session/ui/session_screen.dart';
import 'package:ember/features/session/ui/session_complete_screen.dart';
import 'package:ember/features/workouts/ui/plan_detail_screen.dart';
import 'package:ember/features/workouts/ui/create_edit_plan_screen.dart';
import 'package:flutter/material.dart';
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

      if (authState.isLoading) return null;

      final currentPath = state.matchedLocation;

      if (currentPath == AppRoutes.splash) return null;
      if (_allowAuthenticatedRoutes.contains(currentPath)) return null;
      if (needsProfileSetup) return AppRoutes.profileSetup;

      final isAuthenticated = authState.asData?.value.session != null;
      final isOnPublicRoute = _publicRoutes.contains(currentPath);

      if (isAuthenticated && isOnPublicRoute) return AppRoutes.home;
      if (!isAuthenticated && !isOnPublicRoute) return AppRoutes.welcome;

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
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.changelog,
        builder: (context, state) => const ChangelogScreen(),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.createRoutine,
        builder: (context, state) => const CreateEditRoutineScreen(),
      ),
      GoRoute(
        path: AppRoutes.routineDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RoutineDetailScreen(routineId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.editRoutine,
        builder: (context, state) {
          final routine = state.extra as Routine?;
          return CreateEditRoutineScreen(existingRoutine: routine);
        },
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionComplete,
        builder: (context, state) {
          final summary = state.extra as WorkoutSummary?;
          if (summary == null) {
            // Guard: if navigated without summary, go home.
            return const SizedBox.shrink();
            
          }
          return SessionCompleteScreen(summary: summary);
        },
      ),
      GoRoute(
        path: AppRoutes.createPlan,
        builder: (context, state) => const CreateEditPlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.planDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlanDetailScreen(planId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.editPlan,
        builder: (context, state) {
          final plan = state.extra as WorkoutPlan?;
          return CreateEditPlanScreen(existingPlan: plan);
        },
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