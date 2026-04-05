import 'package:ember/core/router/app_routes.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../data/profile_setup_data.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _selectedAvatarId;

  void _onContinue() {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;
    if (_selectedAvatarId == null) {
      _showAvatarError();
      return;
    }

    ref.read(needsProfileSetupProvider.notifier).setComplete();

    // TODO: wire to profile notifier
    context.go(AppRoutes.home);
  }

  void _showAvatarError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please choose a profile picture to continue.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
              ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Text(
                'Set up your\nprofile.',
                style: textTheme.displayMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you appear in Ember.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 36),

              FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderTextField(
                      name: 'username',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'e.g. ironlifter42',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Username is required.',
                        ),
                        FormBuilderValidators.minLength(
                          3,
                          errorText: 'Username must be at least 3 characters.',
                        ),
                        FormBuilderValidators.maxLength(
                          20,
                          errorText: 'Username must be 20 characters or fewer.',
                        ),
                        FormBuilderValidators.match(
                          RegExp(r'^[a-zA-Z0-9_]+$'),
                          errorText:
                              'Only letters, numbers, and underscores allowed.',
                        ),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Profile Picture',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick one for now — you can change it later.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ProfileSetupData.avatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final avatar = ProfileSetupData.avatars[index];
                  final isSelected = _selectedAvatarId == avatar['id'];

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedAvatarId = avatar['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.lightTextDisabled,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  avatar['label']!,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.lightTextSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _onContinue,
                child: const Text('Continue'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}