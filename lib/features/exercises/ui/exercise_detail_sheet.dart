import 'package:flutter/material.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/exercises/data/exercise_models.dart';
import 'muscle_diagram.dart';

class ExerciseDetailSheet extends StatefulWidget {
  const ExerciseDetailSheet({super.key, required this.exercise});

  final Exercise exercise;

  static void show(BuildContext context, Exercise exercise) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseDetailSheet(exercise: exercise),
    );
  }

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  bool _showFront = true;

  static const Color _primaryOrange = AppColors.primary;

  Exercise get exercise => widget.exercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final primaryFrontIds =
        MuscleHighlightMap.getFrontIds(exercise.muscleGroups);
    final secondaryFrontIds =
        MuscleHighlightMap.getFrontIds(exercise.secondaryMuscles);
    final primaryBackIds =
        MuscleHighlightMap.getBackIds(exercise.muscleGroups);
    final secondaryBackIds =
        MuscleHighlightMap.getBackIds(exercise.secondaryMuscles);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // ── Drag handle ──
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Exercise image ──
                      _ExerciseImage(exercise: exercise),
                      const SizedBox(height: 20),

                      // ── Name + badges ──
                      Text(
                        exercise.name,
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 24,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (exercise.difficulty != null)
                            _DifficultyBadge(
                              difficulty: exercise.difficulty!,
                            ),
                          _CategoryBadge(category: exercise.category),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Muscles ──
                      _DetailSection(
                        title: 'Primary Muscles',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: exercise.muscleGroups
                              .map(
                                (m) => _MuscleTag(
                                  label: m,
                                  isPrimary: true,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      if (exercise.secondaryMuscles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _DetailSection(
                          title: 'Secondary Muscles',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: exercise.secondaryMuscles
                                .map(
                                  (m) => _MuscleTag(
                                    label: m,
                                    isPrimary: false,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // ── Equipment ──
                      _DetailSection(
                        title: 'Equipment',
                        child: exercise.equipment.isEmpty
                            ? Text(
                                'No equipment needed',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: exercise.equipment
                                    .map((eq) => _EquipmentTag(label: eq))
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // ── Muscle diagram ──
                      _DetailSection(
                        title: 'Muscle Diagram',
                        child: Column(
                          children: [
                            // Front / Back toggle
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: colorScheme.outline),
                              ),
                              child: Row(
                                children: [
                                  _DiagramToggle(
                                    label: 'Front',
                                    isActive: _showFront,
                                    onTap: () =>
                                        setState(() => _showFront = true),
                                  ),
                                  _DiagramToggle(
                                    label: 'Back',
                                    isActive: !_showFront,
                                    onTap: () =>
                                        setState(() => _showFront = false),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            MuscleDiagram(
                              primaryMuscleIds: _showFront
                                  ? primaryFrontIds
                                  : primaryBackIds,
                              secondaryMuscleIds: _showFront
                                  ? secondaryFrontIds
                                  : secondaryBackIds,
                              isFront: _showFront,
                              height: 300,
                            ),
                            const SizedBox(height: 8),
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _DiagramLegendItem(
                                  color: _primaryOrange,
                                  label: 'Primary',
                                ),
                                const SizedBox(width: 16),
                                _DiagramLegendItem(
                                  color: AppColors.accent,
                                  label: 'Secondary',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Instructions ──
                      _DetailSection(
                        title: 'How to Perform',
                        child: _NumberedSteps(
                          steps: exercise.instructions
                              .split('\n')
                              .where((s) => s.trim().isNotEmpty)
                              .toList(),
                        ),
                      ),

                      // ── Breathing cues ──
                      if (exercise.breathingCues != null &&
                          exercise.breathingCues!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _DetailSection(
                          title: 'Breathing',
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _primaryOrange.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _primaryOrange.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.air_rounded,
                                  color: _primaryOrange,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    exercise.breathingCues!,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 13,
                                      height: 1.6,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ── Dos and Don'ts ──
                      if (exercise.dos.isNotEmpty ||
                          exercise.donts.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _DetailSection(
                          title: "Do's and Don'ts",
                          child: Column(
                            children: [
                              if (exercise.dos.isNotEmpty)
                                _DosDontsCard(
                                  items: exercise.dos,
                                  isDo: true,
                                ),
                              if (exercise.dos.isNotEmpty &&
                                  exercise.donts.isNotEmpty)
                                const SizedBox(height: 10),
                              if (exercise.donts.isNotEmpty)
                                _DosDontsCard(
                                  items: exercise.donts,
                                  isDo: false,
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── XP reward ──
                      if (exercise.xpReward > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryOrange.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: _primaryOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Earn ${exercise.xpReward} Ember XP per set',
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.darkTextPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        exercise.imageAssetPath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final ExerciseDifficulty difficulty;

  Color _color() {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return AppColors.success;
      case ExerciseDifficulty.intermediate:
        return AppColors.accent;
      case ExerciseDifficulty.advanced:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        difficulty.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final ExerciseCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _MuscleTag extends StatelessWidget {
  const _MuscleTag({required this.label, required this.isPrimary});
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? AppColors.primary : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
      ),
    );
  }
}

class _EquipmentTag extends StatelessWidget {
  const _EquipmentTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
      ),
    );
  }
}

class _NumberedSteps extends StatelessWidget {
  const _NumberedSteps({required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value.trim();
        // Strip leading number if already present (e.g. "1. Stand with feet...")
        final cleaned = step.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cleaned,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DosDontsCard extends StatelessWidget {
  const _DosDontsCard({required this.items, required this.isDo});
  final List<String> items;
  final bool isDo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = isDo ? AppColors.success : AppColors.secondary;
    final icon = isDo ? Icons.check_circle_outline : Icons.cancel_outlined;
    final label = isDo ? "Do's" : "Don'ts";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramToggle extends StatelessWidget {
  const _DiagramToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagramLegendItem extends StatelessWidget {
  const _DiagramLegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}