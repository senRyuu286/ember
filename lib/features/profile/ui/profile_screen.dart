import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming these are your actual imports in your project
import 'package:ember/features/auth/providers/auth_provider.dart';

enum FitnessLevel { beginner, intermediate, advanced }

enum PrimaryGoal {
  buildMuscle,
  loseFat,
  gainStrength,
  improveEndurance,
  generalFitness,
}

enum UnitSystem { lbsMi, kgKm }

enum ThemePreference { system, light, dark }

extension FitnessLevelLabel on FitnessLevel {
  String get label {
    switch (this) {
      case FitnessLevel.beginner: return 'Beginner';
      case FitnessLevel.intermediate: return 'Intermediate';
      case FitnessLevel.advanced: return 'Advanced';
    }
  }
}

extension PrimaryGoalLabel on PrimaryGoal {
  String get label {
    switch (this) {
      case PrimaryGoal.buildMuscle: return 'Build Muscle';
      case PrimaryGoal.loseFat: return 'Lose Fat';
      case PrimaryGoal.gainStrength: return 'Gain Strength';
      case PrimaryGoal.improveEndurance: return 'Improve Endurance';
      case PrimaryGoal.generalFitness: return 'General Fitness';
    }
  }
}

extension UnitSystemLabel on UnitSystem {
  String get label {
    switch (this) {
      case UnitSystem.lbsMi: return 'lbs / mi';
      case UnitSystem.kgKm: return 'kg / km';
    }
  }
}

extension ThemePreferenceLabel on ThemePreference {
  String get label {
    switch (this) {
      case ThemePreference.system: return 'System';
      case ThemePreference.light: return 'Light';
      case ThemePreference.dark: return 'Dark';
    }
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Brand Colors (Aligned with Ember Theme)
  static const Color _bgColor = Color(0xFFDEE1E9);
  static const Color _primaryOrange = Color(0xFFFA4D1A);

  bool _isEditing = false;
  bool _notificationsEnabled = true;
  FitnessLevel _fitnessLevel = FitnessLevel.intermediate;
  PrimaryGoal _primaryGoal = PrimaryGoal.improveEndurance;
  UnitSystem _unitSystem = UnitSystem.lbsMi;
  int _restTimerSeconds = 60;
  ThemePreference _themePreference = ThemePreference.system;

  static const String _userName = 'Alex Fitness';
  static const String _userBio =
      'Training for the 2026 Mandaue marathon, one fiery run at a time.';

  static const _metrics = [
    _MetricData(
      icon: Icons.local_fire_department_rounded,
      value: '18',
      label: 'Streak Days',
    ),
    _MetricData(
      icon: Icons.fitness_center_rounded,
      value: '42',
      label: 'Workouts',
    ),
    _MetricData(
      icon: Icons.bolt_rounded,
      value: '1,280',
      label: 'Ember XP',
    ),
    _MetricData(
      icon: Icons.emoji_events_rounded,
      value: '3',
      label: 'PRs This Month',
    ),
  ];

  Future<void> _handleLogOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC91A25),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    await ref.read(signOutNotifierProvider.notifier).signOut();

    if (!mounted) return;

    final signOutState = ref.read(signOutNotifierProvider);
    if (signOutState.hasError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Failed to log out. Please try again.'),
          ),
        );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSigningOut = ref.watch(signOutNotifierProvider).isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 24),
                
                // ── Identity Card (High Contrast Ember Style) ──
                _IdentityCard(
                  userName: _userName,
                  userBio: _userBio,
                  fitnessLevel: _fitnessLevel,
                  isEditing: _isEditing,
                  onEditToggle: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isEditing = !_isEditing);
                  },
                  onLevelChanged: (level) => setState(() => _fitnessLevel = level),
                ),
                const SizedBox(height: 24),

                // ── Metrics Row ──
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _metrics.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _MetricChip(
                      data: _metrics[index],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Preferences Section ──
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
                              value: _primaryGoal,
                              items: PrimaryGoal.values,
                              labelOf: (g) => g.label,
                              onChanged: (g) => setState(() => _primaryGoal = g),
                            )
                          : _ValueLabel(label: _primaryGoal.label),
                    ),
                    _PreferenceTile(
                      icon: Icons.monitor_weight_rounded,
                      title: 'Unit System',
                      trailing: _CompactDropdown<UnitSystem>(
                        value: _unitSystem,
                        items: UnitSystem.values,
                        labelOf: (s) => s.label,
                        onChanged: (s) => setState(() => _unitSystem = s),
                      ),
                    ),
                    _PreferenceTile(
                      icon: Icons.timer_rounded,
                      title: 'Rest Timer',
                      trailing: PopupMenuButton<int>(
                        initialValue: _restTimerSeconds,
                        onSelected: (s) {
                          HapticFeedback.selectionClick();
                          setState(() => _restTimerSeconds = s);
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
                              '${_restTimerSeconds}s',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.expand_more_rounded,
                              size: 18,
                              color: Colors.black54,
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
                        value: _themePreference,
                        items: ThemePreference.values,
                        labelOf: (t) => t.label,
                        onChanged: (t) => setState(() => _themePreference = t),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Notifications Section ──
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
                        value: _notificationsEnabled,
                        activeThumbColor: _primaryOrange,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          setState(() => _notificationsEnabled = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Actions Section ──
                _SectionContainer(
                  title: 'Actions',
                  subtitle: 'Legal and support quick links',
                  icon: Icons.flash_on_rounded,
                  children: [
                    _ActionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Options',
                      onTap: () => _showActionMessage('Open Privacy Options'),
                    ),
                    _ActionTile(
                      icon: Icons.gavel_rounded,
                      title: 'Terms and Conditions',
                      onTap: () => _showActionMessage('Open Terms & Conditions'),
                    ),
                    _ActionTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () => _showActionMessage('Open Help & Support'),
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
                
                // Bottom Padding for Nav Bar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Image.asset(
          'assets/logo/logo-primary@2x.png',
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.local_fire_department, color: _primaryOrange, size: 32);
          },
        ),
        const SizedBox(width: 12),
        Text(
          "Profile",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Components
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.userName,
    required this.userBio,
    required this.fitnessLevel,
    required this.isEditing,
    required this.onEditToggle,
    required this.onLevelChanged,
  });

  final String userName;
  final String userBio;
  final FitnessLevel fitnessLevel;
  final bool isEditing;
  final VoidCallback onEditToggle;
  final ValueChanged<FitnessLevel> onLevelChanged;

  static const Color _primaryOrange = Color(0xFFFA4D1A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black87, // High contrast Ember feel
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primaryOrange.withValues(alpha: 0.12),
                  border: Border.all(
                    color: _primaryOrange,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: _primaryOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isEditing)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: _CompactDropdown<FitnessLevel>(
                          value: fitnessLevel,
                          items: FitnessLevel.values,
                          labelOf: (l) => l.label,
                          onChanged: onLevelChanged,
                          textColor: Colors.white,
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
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            userBio,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white70,
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

  static const Color _primaryOrange = Color(0xFFFA4D1A);

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
        style: GoogleFonts.inter(
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

  static const Color _primaryOrange = Color(0xFFFA4D1A);

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
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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

  static const Color _primaryOrange = Color(0xFFFA4D1A);
  static const Color _surfaceColor = Color(0xFFF9FAFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                data.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
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

  static const Color _primaryOrange = Color(0xFFFA4D1A);
  static const Color _surfaceColor = Color(0xFFF9FAFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
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
            color: Colors.black.withValues(alpha: 0.05),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
            color: Colors.black.withValues(alpha: 0.05),
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
    const destructiveColor = Color(0xFFC91A25);
    final iconColor = isDestructive ? destructiveColor : Colors.black54;
    final titleColor = isDestructive ? destructiveColor : Colors.black87;

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
                    style: GoogleFonts.inter(
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
                    color: Colors.black.withValues(alpha: 0.2),
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
            color: Colors.black.withValues(alpha: 0.05),
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
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
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
    this.textColor = const Color(0xFFFA4D1A), // Defaults to primaryOrange
  });

  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        borderRadius: BorderRadius.circular(14),
        isDense: true,
        dropdownColor: const Color(0xFFF9FAFF), // _surfaceColor
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        icon: Icon(
          Icons.expand_more_rounded,
          size: 16,
          color: textColor,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelOf(item),
                  style: GoogleFonts.inter(color: Colors.black87), // Fix dropdown list text color
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