import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/data/profile_models.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const Color _primaryOrange = AppColors.primary;

  bool _isEditing = false;
  late TextEditingController _bioController;
  FitnessLevel? _editingFitnessLevel;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfile profile) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;
    _bioController.text = profile.bio ?? '';
    _editingFitnessLevel = profile.fitnessLevel;
  }

  Future<void> _handleDone(UserProfile profile) async {
    HapticFeedback.mediumImpact();
    setState(() => _isEditing = false);

    await ref.read(userProfileProvider.notifier).saveEditableFields(
          bio: _bioController.text.trim(),
          fitnessLevel: _editingFitnessLevel ?? profile.fitnessLevel,
        );
  }

  void _showAvatarPicker(String currentAvatarId) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Choose Avatar',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap one to update your profile picture.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),

              // Avatar grid -- StatefulBuilder so selection state is local
              // to the sheet without rebuilding the whole screen.
              StatefulBuilder(
                builder: (context, setSheetState) {
                  String selectedId = currentAvatarId;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final avatarId = '${index + 1}';
                      final isSelected = selectedId == avatarId;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() => selectedId = avatarId);

                          // Save immediately and close the sheet.
                          ref
                              .read(userProfileProvider.notifier)
                              .updatePreference(avatarId: avatarId);

                          Navigator.of(context).pop();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _primaryOrange
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9.5),
                                child: Image.asset(
                                  'assets/avatars/avatar_$avatarId.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, _, _) => Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: _primaryOrange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 12,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              // Safe area bottom padding
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        content: Text(
          'Are you sure you want to log out?',
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: Text(
              'Log Out',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    await ref.read(profileLocalRepositoryProvider).clearProfile();
    await ref.read(signOutNotifierProvider.notifier).signOut();
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _primaryOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Image.asset(
                'assets/logo/logo-primary@2x.png',
                width: 36,
                height: 36,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.local_fire_department,
                  color: _primaryOrange,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ember',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 22,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ember is your free, offline-capable workout companion. '
              'Plan your training, track your progress, and build the '
              'habit — one session at a time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 Ember. All rights reserved.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final isSigningOut = ref.watch(signOutNotifierProvider).isLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final overlayStyle =
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: SafeArea(
          child: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load profile.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(userProfileProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (profile) {
              if (profile == null) {
                return const Center(child: Text('No profile found.'));
              }

              _initFromProfile(profile);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 24),

                    _IdentityCard(
                      username: profile.username ?? '',
                      avatarId: profile.avatarId,
                      bio: _isEditing ? null : (profile.bio ?? ''),
                      bioController: _bioController,
                      fitnessLevel: _isEditing
                          ? (_editingFitnessLevel ?? profile.fitnessLevel)
                          : profile.fitnessLevel,
                      isEditing: _isEditing,
                      onEditToggle: () {
                        if (_isEditing) {
                          _handleDone(profile);
                        } else {
                          _editingFitnessLevel = profile.fitnessLevel;
                          _bioController.text = profile.bio ?? '';
                          HapticFeedback.lightImpact();
                          setState(() => _isEditing = true);
                        }
                      },
                      onLevelChanged: (level) =>
                          setState(() => _editingFitnessLevel = level),
                      // Only hookup the picker when in edit mode.
                      onAvatarTap: _isEditing
                          ? () => _showAvatarPicker(profile.avatarId)
                          : null,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 104,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _MetricChip(
                            data: _MetricData(
                              icon: Icons.local_fire_department_rounded,
                              value: '${profile.streakCount}',
                              label: 'Streak Days',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _MetricChip(
                            data: _MetricData(
                              icon: Icons.fitness_center_rounded,
                              value: '${profile.totalWorkoutsCompleted}',
                              label: 'Workouts',
                            ),
                          ),
                          const SizedBox(width: 12),
                          _MetricChip(
                            data: _MetricData(
                              icon: Icons.bolt_rounded,
                              value: _formatXp(profile.emberXp),
                              label: 'Ember XP',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    _SectionContainer(
                      title: 'Preferences',
                      subtitle: 'Personal defaults for your sessions',
                      icon: Icons.tune_rounded,
                      children: [
                        _PreferenceTile(
                          icon: Icons.track_changes_rounded,
                          title: 'Primary Goal',
                          trailing: _isEditing
                              ? _CompactDropdown<PrimaryGoal>(
                                  value: profile.primaryGoal,
                                  items: PrimaryGoal.values,
                                  labelOf: (g) => g.label,
                                  onChanged: (g) {
                                    ref
                                        .read(userProfileProvider.notifier)
                                        .updatePreference(primaryGoal: g);
                                  },
                                )
                              : _ValueLabel(label: profile.primaryGoal.label),
                        ),
                        _PreferenceTile(
                          icon: Icons.monitor_weight_rounded,
                          title: 'Unit System',
                          trailing: _CompactDropdown<UnitSystem>(
                            value: profile.unitSystem,
                            items: UnitSystem.values,
                            labelOf: (s) => s.label,
                            onChanged: (s) {
                              ref
                                  .read(userProfileProvider.notifier)
                                  .updatePreference(unitSystem: s);
                            },
                          ),
                        ),
                        _PreferenceTile(
                          icon: Icons.timer_rounded,
                          title: 'Rest Timer',
                          trailing: PopupMenuButton<int>(
                            initialValue: profile.defaultRestTimerSeconds,
                            onSelected: (s) {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(userProfileProvider.notifier)
                                  .updatePreference(
                                    defaultRestTimerSeconds: s,
                                  );
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 30, child: Text('30 s')),
                              PopupMenuItem(value: 45, child: Text('45 s')),
                              PopupMenuItem(value: 60, child: Text('60 s')),
                              PopupMenuItem(value: 90, child: Text('90 s')),
                              PopupMenuItem(value: 120, child: Text('120 s')),
                            ],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${profile.defaultRestTimerSeconds}s',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _PreferenceTile(
                          icon: Icons.palette_rounded,
                          title: 'Theme',
                          showDivider: false,
                          trailing: _CompactDropdown<ThemePreference>(
                            value: profile.theme,
                            items: ThemePreference.values,
                            labelOf: (t) => t.label,
                            onChanged: (t) {
                              ref
                                  .read(userProfileProvider.notifier)
                                  .updatePreference(theme: t);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _SectionContainer(
                      title: 'Notifications',
                      subtitle: 'Control what gets surfaced to you',
                      icon: Icons.notifications_active_rounded,
                      children: [
                        _PreferenceTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Pop-up Notification',
                          showDivider: false,
                          trailing: Switch.adaptive(
                            value: profile.notificationsEnabled,
                            activeThumbColor: _primaryOrange,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(userProfileProvider.notifier)
                                  .updatePreference(
                                    notificationsEnabled: val,
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _SectionContainer(
                      title: 'Actions',
                      subtitle: 'Legal and support quick links',
                      icon: Icons.flash_on_rounded,
                      children: [
                        _ActionTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About Ember',
                          onTap: _showAboutDialog,
                        ),
                        _ActionTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Options',
                          onTap: () =>
                              _showActionMessage('Open Privacy Options'),
                        ),
                        _ActionTile(
                          icon: Icons.gavel_rounded,
                          title: 'Terms and Conditions',
                          onTap: () =>
                              _showActionMessage('Open Terms & Conditions'),
                        ),
                        _ActionTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          onTap: () =>
                              _showActionMessage('Open Help & Support'),
                        ),
                        _ActionTile(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          isDestructive: true,
                          isLoading: isSigningOut,
                          showDivider: false,
                          onTap: isSigningOut ? () {} : _handleLogOut,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo/logo-primary@2x.png',
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.local_fire_department,
            color: _primaryOrange,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Profile',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
        ),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      final k = xp / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return '$xp';
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.username,
    required this.avatarId,
    required this.bio,
    required this.bioController,
    required this.fitnessLevel,
    required this.isEditing,
    required this.onEditToggle,
    required this.onLevelChanged,
    this.onAvatarTap,
  });

  final String username;
  final String avatarId;
  final String? bio;
  final TextEditingController bioController;
  final FitnessLevel fitnessLevel;
  final bool isEditing;
  final VoidCallback onEditToggle;
  final ValueChanged<FitnessLevel> onLevelChanged;
  final VoidCallback? onAvatarTap;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar with optional edit overlay ──
              GestureDetector(
                onTap: onAvatarTap,
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _primaryOrange, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/avatars/avatar_$avatarId.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: _primaryOrange.withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 36,
                              color: _primaryOrange,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Edit overlay badge -- only shown in edit mode
                    if (onAvatarTap != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _primaryOrange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.darkSurface,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 11,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            fontSize: 22,
                            color: AppColors.darkTextPrimary,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: 6),
                    if (isEditing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _CompactDropdown<FitnessLevel>(
                          value: fitnessLevel,
                          items: FitnessLevel.values,
                          labelOf: (l) => l.label,
                          onChanged: onLevelChanged,
                          textColor: AppColors.darkTextPrimary,
                        ),
                      )
                    else
                      _LevelBadge(label: fitnessLevel.label),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _EditButton(isEditing: isEditing, onTap: onEditToggle),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.darkTextPrimary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          if (isEditing)
            TextField(
              controller: bioController,
              maxLength: 150,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AppColors.darkTextPrimary.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
              decoration: InputDecoration(
                hintText: 'Write something about yourself...',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: AppColors.darkTextPrimary.withValues(alpha: 0.3),
                    ),
                counterStyle: TextStyle(
                  color: AppColors.darkTextPrimary.withValues(alpha: 0.3),
                ),
                fillColor: AppColors.darkSurfaceVariant,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.darkTextPrimary.withValues(alpha: 0.15),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.darkTextPrimary.withValues(alpha: 0.15),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _primaryOrange),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            )
          else
            Text(
              (bio == null || bio!.isEmpty) ? 'No bio yet.' : bio!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: (bio == null || bio!.isEmpty)
                        ? AppColors.darkTextPrimary.withValues(alpha: 0.3)
                        : AppColors.darkTextPrimary.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
            ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.label});
  final String label;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primaryOrange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _primaryOrange,
            ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.isEditing, required this.onTap});
  final bool isEditing;
  final VoidCallback onTap;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isEditing ? _primaryOrange : Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isEditing ? 'Done' : 'Edit',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
              ),
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.data});
  final _MetricData data;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 110,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: _primaryOrange, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 20,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
              ),
              Text(
                data.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? subtitle;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: _primaryOrange),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              trailing,
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLoading;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const destructiveColor = AppColors.secondary;

    final iconColor =
        isDestructive ? destructiveColor : colorScheme.onSurfaceVariant;
    final titleColor =
        isDestructive ? destructiveColor : colorScheme.onSurface;

    return Column(
      children: [
        InkWell(
          onTap: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),
      ],
    );
  }
}

class _ValueLabel extends StatelessWidget {
  const _ValueLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _CompactDropdown<T> extends StatelessWidget {
  const _CompactDropdown({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.textColor = AppColors.primary,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        borderRadius: BorderRadius.circular(14),
        isDense: true,
        dropdownColor: colorScheme.surface,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
        icon: Icon(Icons.expand_more_rounded, size: 16, color: textColor),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelOf(item),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
            )
            .toList(),
        onChanged: (item) {
          if (item == null) return;
          HapticFeedback.selectionClick();
          onChanged(item);
        },
      ),
    );
  }
}