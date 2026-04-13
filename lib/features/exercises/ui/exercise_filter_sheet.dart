import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/exercises/providers/exercise_provider.dart';

class ExerciseFilterSheet extends ConsumerStatefulWidget {
  const ExerciseFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExerciseFilterSheet(),
    );
  }

  @override
  ConsumerState<ExerciseFilterSheet> createState() =>
      _ExerciseFilterSheetState();
}

class _ExerciseFilterSheetState extends ConsumerState<ExerciseFilterSheet> {
  // Local draft state so changes only apply when the user taps Apply.
  late String? _muscle;
  late String? _equipment;
  late bool _stretchesOnly;


  @override
  void initState() {
    super.initState();
    final current = ref.read(exerciseFiltersProvider);
    _muscle = current.muscle;
    _equipment = current.equipment;
    _stretchesOnly = current.stretchesOnly;
  }

  void _apply() {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(exerciseFiltersProvider.notifier);
    notifier.setMuscle(_muscle);
    notifier.setEquipment(_equipment);
    notifier.setStretchesOnly(_stretchesOnly);
    Navigator.of(context).pop();
  }

  void _clearAll() {
    HapticFeedback.selectionClick();
    setState(() {
      _muscle = null;
      _equipment = null;
      _stretchesOnly = false;
    });
  }

  bool get _hasDraftFilters =>
      _muscle != null || _equipment != null || _stretchesOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muscles = ref.watch(muscleGroupOptionsProvider);
    final equipment = ref.watch(equipmentOptionsProvider);
    final allExercises =
        ref.watch(exerciseListProvider).asData?.value ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // ── Handle ──
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

              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  children: [
                    Text(
                      'Filter Exercises',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    if (_hasDraftFilters)
                      TextButton(
                        onPressed: _clearAll,
                        child: Text(
                          'Clear all',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              Divider(height: 1, color: colorScheme.outlineVariant),

              // ── Scrollable content ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  children: [
                    // ── Stretches toggle ──
                    _SheetSection(
                      title: 'Category',
                      child: _StretchToggle(
                        value: _stretchesOnly,
                        onChanged: (val) =>
                            setState(() => _stretchesOnly = val),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Muscle groups ──
                    _SheetSection(
                      title: 'Muscle Group',
                      subtitle: _muscle,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: muscles.map((muscle) {
                          final isSelected = _muscle == muscle;
                          final count = allExercises
                              .where(
                                (e) =>
                                    e.muscleGroups.contains(muscle) ||
                                    e.secondaryMuscles.contains(muscle),
                              )
                              .length;

                          return _SheetFilterChip(
                            label: muscle,
                            count: count,
                            isSelected: isSelected,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _muscle = isSelected ? null : muscle;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Equipment ──
                    _SheetSection(
                      title: 'Equipment',
                      subtitle: _equipment,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: equipment.map((eq) {
                          final isSelected = _equipment == eq;
                          final count = allExercises
                              .where((e) => e.equipment.contains(eq))
                              .length;

                          return _SheetFilterChip(
                            label: eq,
                            count: count,
                            isSelected: isSelected,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _equipment = isSelected ? null : eq;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // ── Apply button ──
              Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  MediaQuery.of(context).padding.bottom + 16,
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
                  child: ElevatedButton(
                    onPressed: _apply,
                    child: Text(
                      _hasDraftFilters
                          ? 'Apply Filters'
                          : 'Show All Exercises',
                    ),
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
// Sheet sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  const _SheetSection({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final Widget child;
  final String? subtitle;

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
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  subtitle!,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _StretchToggle extends StatelessWidget {
  const _StretchToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.08)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? AppColors.primary.withValues(alpha: 0.4)
                : colorScheme.outline,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.self_improvement_rounded,
              size: 20,
              color: value ? AppColors.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stretches Only',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: value
                          ? AppColors.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Show only stretching exercises',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? AppColors.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetFilterChip extends StatelessWidget {
  const _SheetFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : colorScheme.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}