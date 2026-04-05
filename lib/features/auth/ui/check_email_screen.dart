import 'package:ember/core/router/app_routes.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class CheckEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(authStateProvider, (previous, next) {
      final session = next.asData?.value.session;
      if (session != null && mounted) {
        context.go(AppRoutes.profileSetup);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Check your email',
                style: textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'We sent a confirmation link to',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                widget.email,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Tap the link in that email to activate\nyour account and continue.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Wrong email fallback
              Text(
                'Wrong email address?',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: () => context.go(AppRoutes.signUp),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('Back to Sign Up'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}