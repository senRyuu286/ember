import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/core/router/app_routes.dart';
import 'package:ember/features/exercises/ui/exercise_detail_sheet.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';
import 'package:ember/features/session/providers/session_provider.dart';
import 'package:ember/features/workouts/data/workout_models.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';

class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({super.key, required this.routineId});
  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineAsync =
        ref.watch(routineDetailProvider(routineId));
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final restTimer = ref
            .watch(userProfileProvider)
            .asData
            ?.value
            ?.defaultRestTimerSeconds ??
        60;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: routineAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(routineDetailProvider(routineId)),
              child: const Text('Retry'),
            ),
          ),
          data: (routine) {
            if (routine == null) {
              return const Center(
                  child: Text('Routine not found.'));
            }
            return _RoutineDetailBody(
              routine: routine,
              restTimerSeconds: restTimer,
            );
          },
        ),
      ),
    );
  }
}

class _RoutineDetailBody extends ConsumerWidget {
  const _RoutineDetailBody({
    required this.routine,
    required this.restTimerSeconds,
  });
  final Routine routine;
  final int restTimerSeconds;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeSession = ref.watch(activeSessionProvider);
    final isActiveRoutine = activeSession?.routine.id == routine.id;

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
                    routine.title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (routine.isOwned && !isActiveRoutine) ...[
                  IconButton(
                    onPressed: () => context.push(
                      AppRoutes.editRoutine
                          .replaceFirst(':id', routine.id),
                      extra: routine,
                    ),
                    icon: Icon(Icons.edit_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 20),
                  ),
                  IconButton(
                    onPressed: () =>
                        _confirmDelete(context, ref),
                    icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.secondary,
                        size: 20),
                  ),
                ] else if (routine.isOwned && isActiveRoutine) ...[
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
                          color: _primaryOrange
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
                        if (routine.description != null &&
                            routine.description!.isNotEmpty)
                          Text(
                            routine.description!,
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
                              icon: Icons.timer_outlined,
                              label: routine.formattedDuration(
                                  restTimerSeconds),
                            ),
                            const SizedBox(width: 20),
                            _HeroStat(
                              icon:
                                  Icons.fitness_center_rounded,
                              label:
                                  '${routine.exercises.length} exercises',
                            ),
                            if (routine.lastPerformedAt !=
                                null) ...[
                              const SizedBox(width: 20),
                              _HeroStat(
                                icon: Icons.history_rounded,
                                label: _formatLastPerformed(
                                    routine.lastPerformedAt!),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Exercise list header ──
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _primaryOrange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Exercises',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 18,
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap an exercise to view details.',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Exercise cards ──
                  ...routine.exercises.asMap().entries.map(
                    (entry) {
                      final i = entry.key;
                      final re = entry.value;
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10),
                        child: _ExerciseDetailCard(
                          index: i,
                          routineExercise: re,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Start button ──
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
              child: ElevatedButton.icon(
                onPressed: () => _startSession(context, ref),
                icon: const Icon(Icons.play_arrow_rounded,
                    size: 24),
                label: const Text('Start Workout'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(
      BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(workoutRepositoryProvider);
    try {
      final sessionId = await repo.startSession(
        routineId: routine.id,
        routineName: routine.title,
      );
      ref
          .read(activeSessionProvider.notifier)
          .startSession(sessionId, routine);
      if (context.mounted) context.push(AppRoutes.session);
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

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Routine'),
        content: Text(
          'Are you sure you want to delete "${routine.title}"? This cannot be undone.',
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
          .read(routineListProvider.notifier)
          .deleteRoutine(routine.id);
      if (context.mounted) context.pop();
    }
  }

  String _formatLastPerformed(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
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
        Text(label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 12,
              color: AppColors.darkTextSecondary,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  const _ExerciseDetailCard({
    required this.index,
    required this.routineExercise,
  });
  final int index;
  final RoutineExercise routineExercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ex = routineExercise.exercise;

    return GestureDetector(
      onTap: ex != null
          ? () {
              HapticFeedback.lightImpact();
              ExerciseDetailSheet.show(context, ex);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex?.name ?? routineExercise.exerciseId,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _setsRepsLabel(),
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (ex != null) ...[
              if (ex.muscleGroups.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ex.muscleGroups.first,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4)),
            ],
          ],
        ),
      ),
    );
  }

  String _setsRepsLabel() {
    final weight = routineExercise.targetWeight;
    final unit = routineExercise.targetWeightUnit;
    final base =
        '${routineExercise.targetSets} sets × ${routineExercise.targetReps} reps';
    if (weight != null) {
      return '$base @ ${weight.toStringAsFixed(1)} $unit';
    }
    return base;
  }
}