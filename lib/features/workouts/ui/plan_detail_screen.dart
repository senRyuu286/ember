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
    final completedToday =
      ref.watch(todayCompletedRoutineIdsProvider).asData?.value ??
        <String>{};

    DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

    final currentWeekIdx = plan.currentWeekIndex;
    final todayDate = normalizeDate(DateTime.now());
    final startDate = normalizeDate(plan.startedAt ?? DateTime.now());

    final sortedDays = [...plan.days]
      ..sort((a, b) {
        final weekCmp = a.weekNumber.compareTo(b.weekNumber);
        if (weekCmp != 0) return weekCmp;
        return a.dayOfWeek.compareTo(b.dayOfWeek);
      });
    final dayIndexById = <String, int>{};
    for (int i = 0; i < sortedDays.length; i++) {
      dayIndexById[sortedDays[i].id] = i;
    }

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
                if (plan.isOwned && !plan.isActive) ...[
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
                ] else if (plan.isOwned && plan.isActive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Active',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
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
                      final dayIndex = dayIndexById[day.id] ?? 0;
                      final targetDate =
                        startDate.add(Duration(days: dayIndex));

                      final isCurrentDay = plan.isActive &&
                        !targetDate.isBefore(todayDate) &&
                        !targetDate.isAfter(todayDate);
                      final isPastDay =
                        plan.isActive && targetDate.isBefore(todayDate);

                      final isFutureDay =
                          plan.isActive && targetDate.isAfter(todayDate);

                      final isDayFullyCompleted =
                          isCurrentDay &&
                            !day.isRestDay &&
                          day.routines.isNotEmpty &&
                          day.routines.every((r) =>
                            completedToday.contains(r.routineId));

                      final canStartSession = plan.isActive &&
                        !isFutureDay &&
                        !isPastDay &&
                        !day.isRestDay &&
                        !isDayFullyCompleted;

                      final mappedShortDayName =
                          _shortWeekdayName(targetDate.weekday);

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 8),
                        child: _PlanDayCard(
                          day: day,
                          isCurrentDay: isCurrentDay,
                          isPastDay: isPastDay,
                          isFutureDay:
                              plan.isActive && isFutureDay,
                          mappedShortDayName: mappedShortDayName,
                          completedRoutineIds: completedToday,
                          isDayFullyCompleted: isDayFullyCompleted,
                            onStartSession: canStartSession
                              ? () =>
                                  _startSessionForDay(
                                context,
                                ref,
                                day,
                                completedToday)
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

  Future<void> _startSessionForDay(
    BuildContext context,
    WidgetRef ref,
    PlanDay day,
    Set<String> completedRoutineIds,
  ) async {
    if (day.routines.isEmpty) return;
    HapticFeedback.mediumImpact();

    PlanDayRoutineRef? nextRoutine;
    for (final routine in day.routines) {
      if (!completedRoutineIds.contains(routine.routineId)) {
        nextRoutine = routine;
        break;
      }
    }
    if (nextRoutine == null) return;

    final repo = ref.read(workoutRepositoryProvider);

    try {
      final routine =
          await repo.getRoutineDetail(nextRoutine.routineId);
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

  String _shortWeekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
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

class _PlanDayCard extends ConsumerStatefulWidget {
  const _PlanDayCard({
    required this.day,
    required this.isCurrentDay,
    required this.isPastDay,
    required this.isFutureDay,
    required this.mappedShortDayName,
    required this.onStartSession,
    required this.completedRoutineIds,
    required this.isDayFullyCompleted,
  });
  final PlanDay day;
  final bool isCurrentDay;
  final bool isPastDay;
  final bool isFutureDay;
  final String mappedShortDayName;
  final VoidCallback? onStartSession;
  final Set<String> completedRoutineIds;
  final bool isDayFullyCompleted;

  @override
  ConsumerState<_PlanDayCard> createState() => _PlanDayCardState();
}

class _PlanDayCardState extends ConsumerState<_PlanDayCard> {
  final Set<String> _expandedRoutineIds = <String>{};

  void _toggleRoutine(String routineId) {
    setState(() {
      if (_expandedRoutineIds.contains(routineId)) {
        _expandedRoutineIds.remove(routineId);
      } else {
        _expandedRoutineIds.add(routineId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final isCurrentDay = widget.isCurrentDay;
    final isPastDay = widget.isPastDay;
    final isFutureDay = widget.isFutureDay;
    final onStartSession = widget.onStartSession;
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Day label ──
                SizedBox(
                  width: 42,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mappedShortDayName,
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
                          : widget.isDayFullyCompleted
                              ? Text(
                                  'All routines completed',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                          : Text(
                              '${day.routines.length} routine${day.routines.length == 1 ? '' : 's'} assigned',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                ),

                // ── Start button or status icon ──
                if (onStartSession != null && !day.isRestDay)
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
                else if (isCurrentDay && widget.isDayFullyCompleted)
                  const Icon(Icons.check_circle_rounded,
                      size: 20, color: AppColors.primary)
                else if (isFutureDay)
                  Icon(Icons.lock_outline_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4)),
              ],
            ),
            if (!day.isRestDay && day.routines.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...day.routines.map((routineRef) {
                final isExpanded =
                    _expandedRoutineIds.contains(routineRef.routineId);
                final isCompleted =
                    widget.completedRoutineIds.contains(routineRef.routineId);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _RoutineExpandableCard(
                    routineRef: routineRef,
                    isExpanded: isExpanded,
                    onToggle: () => _toggleRoutine(routineRef.routineId),
                    isCompleted: isCompleted,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoutineExpandableCard extends ConsumerWidget {
  const _RoutineExpandableCard({
    required this.routineRef,
    required this.isExpanded,
    required this.onToggle,
    required this.isCompleted,
  });

  final PlanDayRoutineRef routineRef;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final routineAsync = ref.watch(routineDetailProvider(routineRef.routineId));

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  if (isCompleted)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      routineRef.routineTitle ?? 'Untitled routine',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: routineAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => Text(
                  'Could not load routine details.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
                data: (routine) {
                  final exercises = routine?.exercises ?? const [];
                  if (exercises.isEmpty) {
                    return Text(
                      'No exercises assigned.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < exercises.length; i++) ...[
                        _RoutineExerciseTile(
                          index: i + 1,
                          name: exercises[i].exercise?.name ??
                              'Exercise ${i + 1}',
                          sets: exercises[i].targetSets,
                          reps: exercises[i].targetReps,
                          weight: exercises[i].targetWeight,
                          weightUnit: exercises[i].targetWeightUnit,
                          notes: exercises[i].notes,
                        ),
                        if (i < exercises.length - 1)
                          Divider(
                            height: 10,
                            color: colorScheme.outlineVariant,
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RoutineExerciseTile extends StatelessWidget {
  const _RoutineExerciseTile({
    required this.index,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.weightUnit,
    required this.notes,
  });

  final int index;
  final String name;
  final int sets;
  final int reps;
  final double? weight;
  final String weightUnit;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final weightLabel = weight == null
        ? ''
        : ' • ${_formatWeight(weight!)} $weightUnit';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. $name',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$sets sets x $reps reps$weightLabel',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (notes != null && notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              notes!.trim(),
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatWeight(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
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