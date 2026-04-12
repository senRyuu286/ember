import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/history/data/history_models.dart';
import 'package:ember/features/history/providers/history_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _TopBar(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SummaryStats(),
                ),
                const SizedBox(height: 24),
                _WeekView(),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Logbook(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Image.asset(
          'assets/logo/logo-primary@2x.png',
          width: 32,
          height: 32,
          errorBuilder: (_, _, _) => const Icon(
            Icons.local_fire_department,
            color: _primaryOrange,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Burn History',
          style: textTheme.displayMedium?.copyWith(
            fontSize: 28,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary stats
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryStats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(weekSummaryProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final useKg = profileAsync.asData?.value?.unitSystem.value == 'kg_km';

    return summaryAsync.when(
      loading: () => const _SummaryStatsShimmer(),
      error: (_, _) => const _SummaryStatsShimmer(),
      data: (summary) => Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Volume',
              value: summary.formattedVolume(useKg: useKg),
              icon: Icons.fitness_center_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Workouts',
              value: '${summary.totalWorkouts}',
              icon: Icons.bolt_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Time',
              value: summary.formattedDuration,
              icon: Icons.timer_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatsShimmer extends StatelessWidget {
  const _SummaryStatsShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Container(
            height: 80,
            margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryOrange, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Week view
// ─────────────────────────────────────────────────────────────────────────────

class _WeekView extends ConsumerWidget {
  static const Color _primaryOrange = AppColors.primary;
  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static final _formatter = _MonthYearFormatter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final monday = ref.watch(selectedWeekMondayProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final burnStatusAsync = ref.watch(weekBurnStatusProvider);
    final profileAsync = ref.watch(userProfileProvider);

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Use the real account creation date, falling back to app launch date.
    final createdAt = profileAsync.asData?.value?.createdAt ?? todayDate;
    final createdDateOnly = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );
    final earliestMonday = _mondayOf(createdDateOnly);

    // Back is disabled when the current monday IS the earliest monday.
    final canGoBack = monday.isAfter(earliestMonday);

    // Forward is disabled when the current monday's week contains today
    // or is already in the future (should not happen but guard anyway).
    final nextMonday = monday.add(const Duration(days: 7));
    final canGoForward = nextMonday.isBefore(todayDate) ||
        nextMonday == todayDate ||
        nextMonday
            .isBefore(todayDate.add(const Duration(days: 1))) &&
            monday != _mondayOf(todayDate);

    final burnStatuses = burnStatusAsync.asData?.value ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Month / year + nav arrows ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                _formatter.format(
                  monday,
                  monday.add(const Duration(days: 6)),
                ),
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _NavArrow(
                icon: Icons.chevron_left_rounded,
                enabled: canGoBack,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(selectedWeekMondayProvider.notifier)
                      .goToPreviousWeek();
                },
              ),
              const SizedBox(width: 4),
              _NavArrow(
                icon: Icons.chevron_right_rounded,
                enabled: canGoForward,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(selectedWeekMondayProvider.notifier)
                      .goToNextWeek();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Day cells ──
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              final cellDate = monday.add(Duration(days: index));
              final cellDateOnly = DateTime(
                cellDate.year,
                cellDate.month,
                cellDate.day,
              );
              final isFuture = cellDateOnly.isAfter(todayDate);
              final isSelected = cellDateOnly ==
                  DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );
              final dateKey =
                  '${cellDate.year}-'
                  '${cellDate.month.toString().padLeft(2, '0')}-'
                  '${cellDate.day.toString().padLeft(2, '0')}';
              final burnStatus = burnStatuses[dateKey];

              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(selectedDayProvider.notifier)
                            .selectDay(cellDateOnly);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.darkSurface
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? _primaryOrange
                          : colorScheme.outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _primaryOrange.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Day letter ──
                      Text(
                        _dayLabels[index],
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white60
                              : isFuture
                                  ? colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.3)
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Date number ──
                      Text(
                        '${cellDate.day}',
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 17,
                          color: isSelected
                              ? Colors.white
                              : isFuture
                                  ? colorScheme.onSurface
                                      .withValues(alpha: 0.25)
                                  : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ── Burn status indicator ──
                      _BurnIndicator(
                        burnStatus: burnStatus,
                        isFuture: isFuture,
                        isSelected: isSelected,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Legend ──
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _BurnLegend(),
        ),
      ],
    );
  }

  static DateTime _mondayOf(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Burn indicator -- shown inside each day cell
// ─────────────────────────────────────────────────────────────────────────────

class _BurnIndicator extends StatelessWidget {
  const _BurnIndicator({
    required this.burnStatus,
    required this.isFuture,
    required this.isSelected,
  });

  final String? burnStatus;
  final bool isFuture;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // Future days get an empty placeholder to preserve layout height.
    if (isFuture) {
      return const SizedBox(width: 20, height: 8);
    }

    if (burnStatus == 'workout_done') {
      return Container(
        width: 20,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    if (burnStatus == 'rest_day') {
      return Container(
        width: 20,
        height: 8,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkTextSecondary
              : AppColors.darkTextSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // Inactive -- small hollow circle.
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? Colors.white24
              : (Theme.of(context).colorScheme.onSurface)
                  .withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _BurnLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _LegendItem(
          label: 'Workout',
          textTheme: textTheme,
          colorScheme: colorScheme,
          child: Container(
            width: 14,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _LegendItem(
          label: 'Rest',
          textTheme: textTheme,
          colorScheme: colorScheme,
          child: Container(
            width: 14,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.darkTextSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _LegendItem(
          label: 'Inactive',
          textTheme: textTheme,
          colorScheme: colorScheme,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.child,
    required this.label,
    required this.textTheme,
    required this.colorScheme,
  });

  final Widget child;
  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        child,
        const SizedBox(width: 5),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav arrow
// ─────────────────────────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Month / year formatter
// ─────────────────────────────────────────────────────────────────────────────

class _MonthYearFormatter {
  static const _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  String format(DateTime monday, DateTime sunday) {
    if (monday.month == sunday.month && monday.year == sunday.year) {
      return '${_months[monday.month - 1]} ${monday.year}';
    }

    final startLabel = _months[monday.month - 1].substring(0, 3);
    final endLabel = monday.year == sunday.year
        ? _months[sunday.month - 1].substring(0, 3)
        : '${_months[sunday.month - 1].substring(0, 3)} ${sunday.year}';

    return '$startLabel – $endLabel ${monday.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logbook
// ─────────────────────────────────────────────────────────────────────────────

class _Logbook extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final selectedDay = ref.watch(selectedDayProvider);
    final sessionsAsync = ref.watch(daySessionsProvider);
    final burnStatusAsync = ref.watch(weekBurnStatusProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final useKg = profileAsync.asData?.value?.unitSystem.value == 'kg_km';

    final dateKey =
        '${selectedDay.year}-'
        '${selectedDay.month.toString().padLeft(2, '0')}-'
        '${selectedDay.day.toString().padLeft(2, '0')}';
    final burnStatus = burnStatusAsync.asData?.value[dateKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Logbook',
          style: textTheme.headlineLarge?.copyWith(
            fontSize: 22,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatSelectedDate(selectedDay),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        sessionsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => _LogbookMessage(
            icon: Icons.error_outline_rounded,
            title: 'Could not load sessions.',
            subtitle: 'Pull down to retry.',
            iconColor: AppColors.error,
          ),
          data: (sessions) {
            if (sessions.isNotEmpty) {
              return Column(
                children: sessions
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SessionCard(session: s, useKg: useKg),
                      ),
                    )
                    .toList(),
              );
            }

            if (burnStatus == 'rest_day') {
              return _LogbookMessage(
                icon: Icons.hotel_rounded,
                title: 'Rest day.',
                subtitle:
                    'Recovery is part of the grind. The ember stays lit.',
                iconColor: AppColors.darkTextSecondary,
              );
            }

            return _LogbookMessage(
              icon: Icons.local_fire_department_outlined,
              title: 'No embers burning.',
              subtitle: 'No workout was logged on this day.',
              iconColor: AppColors.primary.withValues(alpha: 0.4),
            );
          },
        ),
      ],
    );
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      '', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[date.weekday]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _LogbookMessage extends StatelessWidget {
  const _LogbookMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 52, color: iconColor),
            const SizedBox(height: 14),
            Text(
              title,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session card
// ─────────────────────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.useKg});

  final WorkoutSession session;
  final bool useKg;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final timeLabel =
        '${session.startedAt.hour.toString().padLeft(2, '0')}:'
        '${session.startedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline, width: 1),
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
          Text(
            timeLabel,
            style: textTheme.labelMedium?.copyWith(
              fontSize: 12,
              color: _primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            session.displayName,
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 19,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatBadge(
                icon: Icons.fitness_center_rounded,
                label: session.formattedVolume(useKg: useKg),
              ),
              const SizedBox(width: 16),
              _StatBadge(
                icon: Icons.timer_outlined,
                label: session.formattedDuration,
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Icon(
                  Icons.replay_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}