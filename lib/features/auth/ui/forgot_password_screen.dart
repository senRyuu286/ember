import 'package:ember/core/router/app_routes.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _emailSent = false;

  Future<void> _onSendReset() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;

    final email = _formKey.currentState!.value['email'] as String;

    await ref
        .read(forgotPasswordNotifierProvider.notifier)
        .sendResetEmail(email: email);

    if (!mounted) return;

    final state = ref.read(forgotPasswordNotifierProvider);
    if (state.hasError) return;

    setState(() => _emailSent = true);
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('user not found') ||
        message.contains('unable to validate email')) {
      return 'No account found with that email address.';
    }
    if (message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resetState = ref.watch(forgotPasswordNotifierProvider);
    final isLoading = resetState.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: isLoading ? null : () => context.go(AppRoutes.signIn),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _emailSent
              ? _buildSuccessState(textTheme)
              : _buildFormState(textTheme, resetState, isLoading),
        ),
      ),
    );
  }

  Widget _buildFormState(
    TextTheme textTheme,
    AsyncValue<void> resetState,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Text(
          'Reset your\npassword.',
          style: textTheme.displayMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we will send you\na link to reset your password.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),

        // Error banner
        if (resetState.hasError) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _friendlyError(resetState.error!),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              FormBuilderTextField(
                name: 'email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enabled: !isLoading,
                onSubmitted: (_) => _onSendReset(),
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Email is required.',
                  ),
                  FormBuilderValidators.email(
                    errorText: 'Enter a valid email address.',
                  ),
                ]),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _onSendReset,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Send Reset Link'),
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => context.go(AppRoutes.signIn),
                  child: RichText(
                    text: TextSpan(
                      text: 'Remembered your password? ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: textTheme.bodyMedium?.copyWith(
                            color: isLoading
                                ? AppColors.lightTextDisabled
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),

        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 40,
            color: AppColors.success,
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
          'We sent a password reset link to your email address. Tap the link to create a new password.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: () => context.go(AppRoutes.signIn),
          child: const Text('Back to Sign In'),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}