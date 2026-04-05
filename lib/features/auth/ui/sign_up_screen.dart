import 'package:ember/core/router/app_routes.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Future<void> _onSignUp() async {
  //   final isValid = _formKey.currentState?.saveAndValidate() ?? false;
  //   if (!isValid) return;

  //   final fields = _formKey.currentState!.value;
  //   final email = fields['email'] as String;
  //   final password = fields['password'] as String;

  //   await ref
  //       .read(signUpNotifierProvider.notifier)
  //       .signUp(email: email, password: password);

  //   if (!mounted) return;

  //   final state = ref.read(signUpNotifierProvider);
  //   if (state.hasError) return;

  //   context.go(AppRoutes.checkEmail, extra: email);
  // }

    Future<void> _onSignUp() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;

    final fields = _formKey.currentState!.value;
    final email = fields['email'] as String;
    final password = fields['password'] as String;

    await ref
        .read(signUpNotifierProvider.notifier)
        .signUp(email: email, password: password);

    if (!mounted) return;

    final state = ref.read(signUpNotifierProvider);
    if (state.hasError) return;

    context.go(AppRoutes.profileSetup);
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('already registered') ||
        message.contains('user already exists')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('weak password') ||
        message.contains('password should be')) {
      return 'Password is too weak. Use at least 8 characters.';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final signUpState = ref.watch(signUpNotifierProvider);
    final isLoading = signUpState.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: isLoading ? null : () => context.go(AppRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Text(
                'Create your\naccount',
                style: textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your workouts today.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Supabase error banner
              if (signUpState.hasError) ...[
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
                          _friendlyError(signUpState.error!),
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
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enabled: !isLoading,
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

                    const SizedBox(height: 20),

                    Text(
                      'Password',
                      style: textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderTextField(
                      name: 'password',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'At least 8 characters',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: isLoading
                              ? null
                              : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Password is required.',
                        ),
                        FormBuilderValidators.minLength(
                          8,
                          errorText: 'Password must be at least 8 characters.',
                        ),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Confirm Password',
                      style: textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderTextField(
                      name: 'confirm_password',
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onSubmitted: (_) => _onSignUp(),
                      decoration: InputDecoration(
                        hintText: 'Re-enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: isLoading
                              ? null
                              : () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                        ),
                      ),
                      validator: (value) {
                        final password =
                            _formKey.currentState?.fields['password']?.value
                                as String?;
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != password) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: isLoading ? null : _onSignUp,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Create Account'),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => context.go(AppRoutes.signIn),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
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
          ),
        ),
      ),
    );
  }
}
