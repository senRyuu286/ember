import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/core/router/app_routes.dart';
import 'package:ember/features/session/providers/session_provider.dart';
import 'package:ember/features/workouts/data/plan_models.dart';
import 'package:ember/features/workouts/providers/plan_provider.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';

class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planDetailProvider(planId));
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: planAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(planDetailProvider(planId)),
              child: const Text('Retry'),
            ),
          ),
          data: (plan) {
            if (plan == null) {
              return const Center(child: Text('Plan not found.'));
            }
            return _PlanDetailBody(plan: plan);
          },
        ),
      ),
    );
  }
}

class _PlanDetailBody extends ConsumerWidget {
  const _PlanDetailBody({required this.plan});
  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final currentWeekIdx = plan.currentWeekIndex;
    final todayDow = plan.todayDayOfWeek;

    return SafeArea(
      child: Column(
        children: [
          // ── App bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurface, size: 20),
                ),
                Expanded(
                  child: Text(
                    plan.title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (plan.isOwned) ...[
                  IconButton(
                    onPressed: () => context.push(
                      AppRoutes.editPlan
                          .replaceFirst(':id', plan.id),
                      extra: plan,
                    ),
                    icon: Icon(Icons.edit_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 20),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.secondary, size: 20),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (plan.description != null &&
                            plan.description!.isNotEmpty)
                          Text(
                            plan.description!,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: AppColors.darkTextSecondary,
                              height: 1.5,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _HeroStat(
                              icon: Icons.calendar_month_rounded,
                              label: plan.totalWeeks == 1
                                  ? '1 week'
                                  : '${plan.totalWeeks} weeks',
                            ),
                            const SizedBox(width: 20),
                            _HeroStat(
                              icon: Icons.fitness_center_rounded,
                              label:
                                  '${plan.days.length} training days',
                            ),
                            if (plan.isActive) ...[
                              const SizedBox(width: 20),
                              _HeroStat(
                                icon:
                                    Icons.play_circle_outline_rounded,
                                label:
                                    'Week ${(currentWeekIdx ?? 0) + 1} of ${plan.totalWeeks}',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Week-by-week ──
                  for (int w = 1; w <= plan.totalWeeks; w++) ...[
                    _WeekHeader(weekNumber: w),
                    const SizedBox(height: 10),
                    ...plan.days
                        .where((d) => d.weekNumber == w)
                        .map((day) {
                      final isCurrentDay = plan.isActive &&
                          currentWeekIdx == (w - 1) &&
                          day.dayOfWeek == todayDow;
                      final isPastDay = plan.isActive &&
                          _isDayInPast(
                              w - 1, day.dayOfWeek,
                              currentWeekIdx, todayDow);
                      final isFutureDay = plan.isActive &&
                          !isCurrentDay &&
                          !isPastDay;

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 8),
                        child: _PlanDayCard(
                          day: day,
                          isCurrentDay: isCurrentDay,
                          isPastDay: isPastDay,
                          isFutureDay:
                              plan.isActive && isFutureDay,
                          onStartSession: isCurrentDay
                              ? () =>
                                  _startSessionForDay(
                                      context, ref, day)
                              : null,
                        ),
                      );
                    }),
                    if (w < plan.totalWeeks)
                      const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // ── Activate / Deactivate button ──
          if (plan.isOwned || plan.isBuiltIn)
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                      color: colorScheme.outlineVariant),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: plan.isActive
                    ? OutlinedButton(
                        onPressed: () =>
                            _deactivatePlan(context, ref),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Deactivate Plan'),
                      )
                    : ElevatedButton.icon(
                        onPressed: () =>
                            _activatePlan(context, ref),
                        icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 22),
                        label: const Text('Activate Plan'),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  /// True if the given week+day is strictly before the current position.
  bool _isDayInPast(
    int weekIdx,
    int dayOfWeek,
    int? currentWeekIdx,
    int todayDow,
  ) {
    if (currentWeekIdx == null) return false;
    if (weekIdx < currentWeekIdx) return true;
    if (weekIdx == currentWeekIdx && dayOfWeek < todayDow) return true;
    return false;
  }

  Future<void> _startSessionForDay(
    BuildContext context,
    WidgetRef ref,
    PlanDay day,
  ) async {
    if (day.routines.isEmpty) return;
    HapticFeedback.mediumImpact();

    // Start with the first routine on the day
    final first = day.routines.first;
    final repo = ref.read(workoutRepositoryProvider);

    try {
      final routine =
          await repo.getRoutineDetail(first.routineId);
      if (routine == null) return;

      final sessionId = await repo.startSession(
        routineId: routine.id,
        routineName: routine.title,
      );
      ref
          .read(activeSessionProvider.notifier)
          .startSession(sessionId, routine);
      if (context.mounted) {
        context.push(AppRoutes.session);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to start session. Please try again.')),
        );
      }
    }
  }

  Future<void> _activatePlan(
      BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    try {
      await ref
          .read(planListProvider.notifier)
          .activatePlan(plan.id);
      await ref.read(planDetailProvider(plan.id).notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '"${plan.title}" is now your active plan.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Failed to activate plan.')),
        );
      }
    }
  }

  Future<void> _deactivatePlan(
      BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    try {
      await ref
          .read(planListProvider.notifier)
          .deactivatePlan(plan.id);
      await ref.read(planDetailProvider(plan.id).notifier).refresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to deactivate plan.')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Plan'),
        content: Text(
          'Are you sure you want to delete "${plan.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(planListProvider.notifier)
          .deletePlan(plan.id);
      if (context.mounted) context.pop();
    }
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.weekNumber});
  final int weekNumber;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Week $weekNumber',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PlanDayCard extends StatelessWidget {
  const _PlanDayCard({
    required this.day,
    required this.isCurrentDay,
    required this.isPastDay,
    required this.isFutureDay,
    required this.onStartSession,
  });
  final PlanDay day;
  final bool isCurrentDay;
  final bool isPastDay;
  final bool isFutureDay;
  final VoidCallback? onStartSession;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color borderColor = colorScheme.outline;
    if (isCurrentDay) borderColor = AppColors.primary;
    if (day.isRestDay) borderColor = colorScheme.outlineVariant;

    return Opacity(
      opacity: isFutureDay ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: day.isRestDay
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: borderColor,
              width: isCurrentDay ? 1.5 : 1),
        ),
        child: Row(
          children: [
            // ── Day label ──
            SizedBox(
              width: 42,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.shortDayName,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isCurrentDay
                          ? AppColors.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (isCurrentDay)
                    Text(
                      'Today',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Content ──
            Expanded(
              child: day.isRestDay
                  ? Text(
                      'Rest day',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    )
                  : day.routines.isEmpty
                      ? Text(
                          'No routines assigned',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        )
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: day.routines
                              .map((r) => Text(
                                    r.routineTitle ?? r.routineId,
                                    style: textTheme.bodySmall
                                        ?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ))
                              .toList(),
                        ),
            ),

            // ── Start button or status icon ──
            if (isCurrentDay && onStartSession != null && !day.isRestDay)
              IconButton(
                onPressed: onStartSession,
                icon: const Icon(Icons.play_arrow_rounded,
                    color: AppColors.primary, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                    minWidth: 32, minHeight: 32),
              )
            else if (isPastDay && !day.isRestDay)
              Icon(Icons.check_circle_outline_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5))
            else if (isFutureDay)
              Icon(Icons.lock_outline_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.darkTextSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 12,
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}