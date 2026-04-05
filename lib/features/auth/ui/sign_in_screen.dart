import 'package:ember/core/router/app_routes.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

  Future<void> _onSignIn() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;

    final fields = _formKey.currentState!.value;
    final email = fields['email'] as String;
    final password = fields['password'] as String;

    await ref.read(signInNotifierProvider.notifier).signIn(
          email: email,
          password: password,
        );

    if (!mounted) return;

    final state = ref.read(signInNotifierProvider);
    if (state.hasError) return;

    context.go(AppRoutes.home);
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password') ||
        message.contains('wrong password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (message.contains('too many requests') ||
        message.contains('rate limit')) {
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
    final signInState = ref.watch(signInNotifierProvider);
    final isLoading = signInState.isLoading;

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
                'Welcome\nback.',
                style: textTheme.displayMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your training.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Error banner
              if (signInState.hasError) ...[
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
                          _friendlyError(signInState.error!),
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
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onSubmitted: (_) => _onSignIn(),
                      decoration: InputDecoration(
                        hintText: 'Your password',
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
                                    () =>
                                        _obscurePassword = !_obscurePassword,
                                  ),
                        ),
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'Password is required.',
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => context.go(AppRoutes.forgotPassword),
                        child: Text(
                          'Forgot password?',
                          style: textTheme.bodySmall?.copyWith(
                            color: isLoading
                                ? AppColors.lightTextDisabled
                                : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: isLoading ? null : _onSignIn,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Sign In'),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => context.go(AppRoutes.signUp),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightTextSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
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