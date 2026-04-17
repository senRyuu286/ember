import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/workouts/data/plan_models.dart';
import 'package:ember/features/workouts/presentation/state/create_edit_plan_state.dart';
import 'package:ember/features/workouts/providers/plan_provider.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';

class CreateEditPlanScreen extends ConsumerWidget {
  const CreateEditPlanScreen({super.key, this.existingPlan});
  final WorkoutPlan? existingPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createEditPlanProvider(existingPlan));
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: PopScope(
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            ref.invalidate(createEditPlanProvider(existingPlan));
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // ── App bar ──
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ref.invalidate(
                              createEditPlanProvider(existingPlan));
                          context.pop();
                        },
                        icon: Icon(Icons.close_rounded,
                            color: colorScheme.onSurface),
                      ),
                      Expanded(
                        child: Text(
                          existingPlan != null
                              ? 'Edit Plan'
                              : 'Forge New Plan',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (state.isSaving)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // ── Plan name ──
                      Text('Plan Name',
                          style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: state.title,
                        onChanged: (v) => ref
                            .read(createEditPlanProvider(existingPlan)
                                .notifier)
                            .setTitle(v),
                        decoration: InputDecoration(
                          hintText: 'e.g. 8-Week Strength Block',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: colorScheme.outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Description ──
                      Text('Description',
                          style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('Optional',
                          style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: state.description,
                        maxLines: 3,
                        onChanged: (v) => ref
                            .read(createEditPlanProvider(existingPlan)
                                .notifier)
                            .setDescription(v),
                        decoration: InputDecoration(
                          hintText: 'What is this plan for?',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: colorScheme.outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Total weeks ──
                      Text('Duration',
                          style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      _WeeksStepper(
                        value: state.totalWeeks,
                        onChanged: (v) => ref
                            .read(createEditPlanProvider(existingPlan)
                                .notifier)
                            .setTotalWeeks(v),
                      ),
                      const SizedBox(height: 28),

                      // ── Weekly schedule ──
                      Row(
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
                          Text('Weekly Schedule',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 18,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Assign routines to each day. Up to 3 rest days per week.',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),

                      for (int w = 1;
                          w <= state.totalWeeks;
                          w++) ...[
                        _WeekSection(
                          weekNumber: w,
                          days: state.days
                              .where((d) => d.weekNumber == w)
                              .toList(),
                          existingPlan: existingPlan,
                          onToggleRest: (dow) => ref
                              .read(createEditPlanProvider(existingPlan)
                                  .notifier)
                              .toggleRestDay(w, dow),
                          onAddRoutine: (dow, id, title) => ref
                              .read(createEditPlanProvider(existingPlan)
                                  .notifier)
                              .addRoutineToDay(w, dow, id, title),
                          onRemoveRoutine: (dow, idx) => ref
                              .read(createEditPlanProvider(existingPlan)
                                  .notifier)
                              .removeRoutineFromDay(w, dow, idx),
                          restDayCount: state.restDayCount(w),
                        ),
                        if (w < state.totalWeeks)
                          const SizedBox(height: 20),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // ── Save button ──
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
                    child: ElevatedButton(
                      onPressed: state.isValid && !state.isSaving
                          ? () => _save(context, ref)
                          : null,
                      child: Text(existingPlan != null
                          ? 'Save Changes'
                          : 'Create Plan'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    if (existingPlan?.isActive == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Active plans cannot be edited.')),
        );
      }
      return;
    }

    HapticFeedback.mediumImpact();
    final notifier =
        ref.read(createEditPlanProvider(existingPlan).notifier);
    try {
      final savedPlanId = await notifier.save(existingPlan?.id);
      await ref.read(planListProvider.notifier).refresh();
      if (savedPlanId != null) {
        ref.invalidate(planDetailProvider(savedPlanId));
      }
      ref.invalidate(createEditPlanProvider(existingPlan));
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save plan.')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weeks stepper
// ─────────────────────────────────────────────────────────────────────────────

class _WeeksStepper extends StatelessWidget {
  const _WeeksStepper(
      {required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > 1
                ? () {
                    HapticFeedback.selectionClick();
                    onChanged(value - 1);
                  }
                : null,
            icon: Icon(Icons.remove_rounded,
                color: value > 1
                    ? colorScheme.onSurface
                    : colorScheme.onSurface
                        .withValues(alpha: 0.3)),
          ),
          Expanded(
            child: Center(
              child: Text(
                value == 1 ? '1 week' : '$value weeks',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: value < 52
                ? () {
                    HapticFeedback.selectionClick();
                    onChanged(value + 1);
                  }
                : null,
            icon: Icon(Icons.add_rounded,
                color: value < 52
                    ? colorScheme.onSurface
                    : colorScheme.onSurface
                        .withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Week section + day row (unchanged from previous write, included for completeness)
// ─────────────────────────────────────────────────────────────────────────────

class _WeekSection extends StatelessWidget {
  const _WeekSection({
    required this.weekNumber,
    required this.days,
    required this.existingPlan,
    required this.onToggleRest,
    required this.onAddRoutine,
    required this.onRemoveRoutine,
    required this.restDayCount,
  });
  final int weekNumber;
  final List<PlanDayState> days;
  final WorkoutPlan? existingPlan;
  final ValueChanged<int> onToggleRest;
  final void Function(int dayOfWeek, String id, String title)
      onAddRoutine;
  final void Function(int dayOfWeek, int index) onRemoveRoutine;
  final int restDayCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Week $weekNumber',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...days.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DayRow(
              day: day,
              canAddRestDay: !day.isRestDay && restDayCount < 3,
              onToggleRest: () => onToggleRest(day.dayOfWeek),
              onAddRoutine: (id, title) =>
                  onAddRoutine(day.dayOfWeek, id, title),
              onRemoveRoutine: (idx) =>
                  onRemoveRoutine(day.dayOfWeek, idx),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayRow extends ConsumerWidget {
  const _DayRow({
    required this.day,
    required this.canAddRestDay,
    required this.onToggleRest,
    required this.onAddRoutine,
    required this.onRemoveRoutine,
  });
  final PlanDayState day;
  final bool canAddRestDay;
  final VoidCallback onToggleRest;
  final void Function(String id, String title) onAddRoutine;
  final ValueChanged<int> onRemoveRoutine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: day.isRestDay
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: day.isRestDay
              ? colorScheme.outlineVariant
              : colorScheme.outline,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                day.dayName.substring(0, 3),
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: day.isRestDay
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (day.isRestDay)
              Expanded(
                child: Text('Rest day',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    )),
              )
            else
              Expanded(
                child: day.routineTitles.isEmpty
                    ? Text('No routines',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                          fontSize: 12,
                        ))
                    : Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: day.routineTitles
                            .asMap()
                            .entries
                            .map((e) => _RoutineChip(
                                  label: e.value,
                                  onRemove: () =>
                                      onRemoveRoutine(e.key),
                                ))
                            .toList(),
                      ),
              ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onToggleRest();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: day.isRestDay
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (canAddRestDay
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day.isRestDay ? 'Unrest' : 'Rest',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: day.isRestDay
                        ? AppColors.primary
                        : (canAddRestDay
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
            if (!day.isRestDay) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.add_rounded,
                    size: 18, color: AppColors.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                    minWidth: 32, minHeight: 32),
                onPressed: () =>
                    _showRoutinePicker(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showRoutinePicker(
      BuildContext context, WidgetRef ref) async {
    final result =
        await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RoutinePickerSheet(),
    );
    if (result == null) return;
    onAddRoutine(result.$1, result.$2);
  }
}

class _RoutineChip extends StatelessWidget {
  const _RoutineChip(
      {required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.only(
          left: 8, right: 4, top: 3, bottom: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 13,
                color:
                    AppColors.primary.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _RoutinePickerSheet extends ConsumerStatefulWidget {
  const _RoutinePickerSheet();

  @override
  ConsumerState<_RoutinePickerSheet> createState() =>
      _RoutinePickerSheetState();
}

class _RoutinePickerSheetState
    extends ConsumerState<_RoutinePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final routines =
        ref.watch(routineListProvider).asData?.value ?? [];

    final filtered = _query.isEmpty
        ? routines
        : routines
            .where((r) => r.title
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            children: [
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
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  onChanged: (v) =>
                      setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search routines...',
                    prefixIcon: Icon(Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor:
                        colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          )),
                      subtitle: Text(
                          '${r.exerciseCount} exercises',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          )),
                      trailing: Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          size: 22),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context)
                            .pop((r.id, r.title));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}