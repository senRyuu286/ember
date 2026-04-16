import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/core/router/app_routes.dart';
import 'package:ember/features/exercises/data/exercise_models.dart';
import 'package:ember/features/exercises/ui/exercise_detail_sheet.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';
import 'package:ember/features/workouts/data/workout_models.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  Timer? _restTimer;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;

  static const Color _primaryOrange = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _startElapsedTimer();
    _syncControllers();
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _syncControllers() {
    final session = ref.read(activeSessionProvider);
    if (session == null) return;
    final ex = session.currentExercise;
    final logs = session.setLogs[ex.exerciseId] ?? [];
    if (session.currentSetIndex < logs.length) {
      final log = logs[session.currentSetIndex];
      _repsController.text = '${log.reps ?? ex.targetReps}';
      _weightController.text =
          log.weight != null ? log.weight!.toStringAsFixed(1) : '';
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _elapsedTimer?.cancel();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = ref.read(activeSessionProvider);
      if (session == null || !session.isResting) {
        _restTimer?.cancel();
        return;
      }
      ref.read(activeSessionProvider.notifier).tickRest();
      if (session.restSecondsRemaining <= 1) {
        _restTimer?.cancel();
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _completeSet(int restSeconds) {
    HapticFeedback.mediumImpact();
    final reps = int.tryParse(_repsController.text);
    final weight = double.tryParse(_weightController.text);

    ref
        .read(activeSessionProvider.notifier)
        .updateCurrentSetLog(reps: reps, weight: weight);
    ref
        .read(activeSessionProvider.notifier)
        .completeCurrentSet(restSeconds);

    final session = ref.read(activeSessionProvider);
    if (session != null && session.isResting) {
      _startRestTimer(session.restSecondsRemaining);
    }
    if (session != null && !session.isFinished) {
      _syncControllers();
    }
    if (session != null && session.isFinished) {
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    _restTimer?.cancel();
    _elapsedTimer?.cancel();

    final session = ref.read(activeSessionProvider);
    if (session == null) return;

    final remaining = session.totalSetsCount - session.completedSetsCount;

    if (remaining > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Finish Workout?'),
          content: Text(
            'You have $remaining set${remaining > 1 ? 's' : ''} remaining. '
            'Finish anyway and log what you completed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep Going'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary),
              child: const Text('Finish'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        _startElapsedTimer();
        return;
      }
    }

    await _writeSession(session);
  }

  Future<void> _writeSession(SessionState session) async {
    final notifier = ref.read(activeSessionProvider.notifier);
    final repo = ref.read(workoutRepositoryProvider);

    // Build summary BEFORE clearing state.
    final summary = notifier.buildSummary(_elapsedSeconds);
    final loggedSets = notifier.collectLoggedSets();
    final totalVolume = notifier.totalVolumeLbs();

    try {
      await repo.finishSession(
        sessionId: session.sessionId,
        routineId: session.routine.id,
        durationSeconds: _elapsedSeconds,
        totalVolumeLbs: totalVolume,
        loggedSets: loggedSets,
      );
    } catch (_) {}

    notifier.clearSession();

    if (mounted) {
      // Replace session screen with completion screen.
      context.go(AppRoutes.sessionComplete, extra: summary);
    }
  }

  String _formatElapsed(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);
    if (session == null) {
      return const Scaffold(
          body: Center(child: Text('No active session.')));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final currentEx = session.currentExercise;
    final exercise = currentEx.exercise;
    final logs = session.setLogs[currentEx.exerciseId] ?? [];
    final restSeconds = ref
            .watch(userProfileProvider)
            .asData
            ?.value
            ?.defaultRestTimerSeconds ??
        60;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _finishSession(),
                      icon: Icon(Icons.close_rounded,
                          color: colorScheme.onSurface),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.routine.title,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatElapsed(_elapsedSeconds),
                            style: textTheme.headlineSmall?.copyWith(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${session.completedSetsCount}/${session.totalSetsCount} sets',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Progress bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: LinearProgressIndicator(
                  value: session.totalSetsCount > 0
                      ? session.completedSetsCount / session.totalSetsCount
                      : 0,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: _primaryOrange,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: session.isResting
                    ? _RestView(
                        secondsRemaining: session.restSecondsRemaining,
                        nextExercise: session.nextExercise,
                        onSkip: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(activeSessionProvider.notifier)
                              .skipRest();
                          _restTimer?.cancel();
                          _syncControllers();
                        },
                      )
                    : _ExerciseView(
                        exercise: exercise,
                        currentExercise: currentEx,
                        exerciseIndex: session.currentExerciseIndex,
                        totalExercises: session.routine.exercises.length,
                        currentSetIndex: session.currentSetIndex,
                        logs: logs,
                        repsController: _repsController,
                        weightController: _weightController,
                        onCompleteSet: () => _completeSet(restSeconds),
                        onFinish: _finishSession,
                        isLastSet: session.isLastSet,
                        isLastExercise: session.isLastExercise,
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
// Exercise view
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseView extends StatelessWidget {
  const _ExerciseView({
    required this.exercise,
    required this.currentExercise,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.currentSetIndex,
    required this.logs,
    required this.repsController,
    required this.weightController,
    required this.onCompleteSet,
    required this.onFinish,
    required this.isLastSet,
    required this.isLastExercise,
  });

  final Exercise? exercise;
  final RoutineExercise currentExercise;
  final int exerciseIndex;
  final int totalExercises;
  final int currentSetIndex;
  final List<SetLog> logs;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final VoidCallback onCompleteSet;
  final VoidCallback onFinish;
  final bool isLastSet;
  final bool isLastExercise;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final exName = exercise?.name ?? currentExercise.exerciseId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Exercise ${exerciseIndex + 1} of $totalExercises',
            style: textTheme.labelMedium?.copyWith(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exName,
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 26,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (exercise != null)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ExerciseDetailSheet.show(context, exercise!);
                  },
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('How to'),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          if (exercise?.muscleGroups.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exercise!.muscleGroups.first,
                style: textTheme.labelSmall?.copyWith(
                  color: _primaryOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: List.generate(currentExercise.targetSets, (i) {
              final isCompleted = i < logs.length && logs[i].isCompleted;
              final isCurrent = i == currentSetIndex;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? _primaryOrange
                        : isCurrent
                            ? _primaryOrange.withValues(alpha: 0.4)
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Set ${currentSetIndex + 1} of ${currentExercise.targetSets}',
            style: textTheme.labelMedium?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SessionField(
                  label: 'Reps',
                  controller: repsController,
                  hint: '${currentExercise.targetReps}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SessionField(
                  label: 'Weight (${currentExercise.targetWeightUnit})',
                  controller: weightController,
                  hint: 'Optional',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onCompleteSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isLastSet && isLastExercise
                    ? 'Complete Workout'
                    : isLastSet
                        ? 'Complete Set → Next Exercise'
                        : 'Complete Set',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (logs.any((l) => l.isCompleted)) ...[
            const SizedBox(height: 28),
            Text('Completed Sets',
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                )),
            const SizedBox(height: 8),
            ...logs.where((l) => l.isCompleted).map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: _primaryOrange),
                    const SizedBox(width: 8),
                    Text(
                      'Set ${l.setNumber}: ${l.reps ?? '-'} reps'
                      '${l.weight != null ? ' @ ${l.weight!.toStringAsFixed(1)} ${currentExercise.targetWeightUnit}' : ''}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rest view
// ─────────────────────────────────────────────────────────────────────────────

class _RestView extends StatelessWidget {
  const _RestView({
    required this.secondsRemaining,
    required this.nextExercise,
    required this.onSkip,
  });

  final int secondsRemaining;
  final RoutineExercise? nextExercise;
  final VoidCallback onSkip;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkSurface,
                boxShadow: [
                  BoxShadow(
                    color: _primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$secondsRemaining',
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: _primaryOrange,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      'REST',
                      style: textTheme.labelMedium?.copyWith(
                        fontSize: 13,
                        color: AppColors.darkTextSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (nextExercise != null) ...[
              Text('Up Next',
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  )),
              const SizedBox(height: 6),
              Text(
                nextExercise!.exercise?.name ?? nextExercise!.exerciseId,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${nextExercise!.targetSets} sets × ${nextExercise!.targetReps} reps',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
            ] else
              const SizedBox(height: 28),
            OutlinedButton(
              onPressed: onSkip,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48),
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Skip Rest'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session input field
// ─────────────────────────────────────────────────────────────────────────────

class _SessionField extends StatelessWidget {
  const _SessionField({
    required this.label,
    required this.controller,
    required this.hint,
  });
  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}