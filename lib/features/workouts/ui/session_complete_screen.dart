import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/core/router/app_routes.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';

class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({super.key, required this.summary});
  final WorkoutSummary summary;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Flame icon + headline ──
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _primaryOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: _primaryOrange,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Workout Complete!',
                        style: textTheme.displaySmall?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.routineTitle,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // ── Top-level stats row ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryOrange.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatTile(
                              icon: Icons.timer_outlined,
                              value: summary.formattedDuration,
                              label: 'Duration',
                            ),
                            _VerticalDivider(),
                            _StatTile(
                              icon: Icons.fitness_center_rounded,
                              value: '${summary.totalSetsCompleted}',
                              label: 'Sets',
                            ),
                            _VerticalDivider(),
                            _StatTile(
                              icon: Icons.monitor_weight_outlined,
                              value: summary.totalVolumeLbs > 0
                                  ? '${summary.totalVolumeLbs.toStringAsFixed(0)} lbs'
                                  : '—',
                              label: 'Volume',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Per-exercise breakdown ──
                      if (summary.exercises.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
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
                              Text(
                                'Exercise Breakdown',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 18,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...summary.exercises.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ex = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ExerciseBreakdownCard(
                              index: i,
                              exercise: ex,
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Back to home button ──
              Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.home_rounded, size: 22),
                    label: const Text('Back to Home'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, color: AppColors.darkTextSecondary, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11,
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class _ExerciseBreakdownCard extends StatelessWidget {
  const _ExerciseBreakdownCard({
    required this.index,
    required this.exercise,
  });
  final int index;
  final ExerciseSummary exercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final volumeText = exercise.totalWeightLbs != null && exercise.totalWeightLbs! > 0
        ? '${exercise.totalWeightLbs!.toStringAsFixed(0)} lbs total volume'
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          // ── Index badge ──
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
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

          // ── Exercise name + stats ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.setsCompleted} sets · ${exercise.totalReps} total reps',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (volumeText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    volumeText,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Completion check ──
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}