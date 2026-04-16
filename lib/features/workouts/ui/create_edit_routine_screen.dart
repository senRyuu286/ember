import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/exercises/data/exercise_models.dart';
import 'package:ember/features/exercises/providers/exercise_provider.dart';
import 'package:ember/features/exercises/ui/exercise_filter_sheet.dart';
import 'package:ember/features/workouts/data/workout_models.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';

class CreateEditRoutineScreen extends ConsumerWidget {
  const CreateEditRoutineScreen({super.key, this.existingRoutine});
  final Routine? existingRoutine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(createEditRoutineProvider(existingRoutine));
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: PopScope(
        // Invalidate state when the user closes via back gesture or close button.
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            ref.invalidate(
                createEditRoutineProvider(existingRoutine));
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
                              createEditRoutineProvider(
                                  existingRoutine));
                          context.pop();
                        },
                        icon: Icon(Icons.close_rounded,
                            color: colorScheme.onSurface),
                      ),
                      Expanded(
                        child: Text(
                          existingRoutine != null
                              ? 'Edit Routine'
                              : 'Forge New Routine',
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

                // ── Sliver body (fixes reorder + scroll conflict) ──
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            20, 20, 20, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // ── Title ──
                            Text('Routine Name',
                                style: textTheme.labelLarge
                                    ?.copyWith(
                                        color:
                                            colorScheme.onSurface)),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: state.title,
                              onChanged: (v) => ref
                                  .read(
                                    createEditRoutineProvider(
                                            existingRoutine)
                                        .notifier,
                                  )
                                  .setTitle(v),
                              decoration: InputDecoration(
                                hintText: 'e.g. Monday Push Day',
                                filled: true,
                                fillColor: colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Description ──
                            Text('Description',
                                style: textTheme.labelLarge
                                    ?.copyWith(
                                        color:
                                            colorScheme.onSurface)),
                            const SizedBox(height: 4),
                            Text('Optional',
                                style: textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                )),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: state.description,
                              maxLines: 3,
                              onChanged: (v) => ref
                                  .read(
                                    createEditRoutineProvider(
                                            existingRoutine)
                                        .notifier,
                                  )
                                  .setDescription(v),
                              decoration: InputDecoration(
                                hintText:
                                    'What is this routine for?',
                                filled: true,
                                fillColor: colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.outline),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Exercise list header ──
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius:
                                        BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Exercises',
                                  style: textTheme.headlineMedium
                                      ?.copyWith(
                                    fontSize: 18,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${state.exercises.length})',
                                  style: textTheme.bodySmall
                                      ?.copyWith(
                                    color: colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Hold and drag to reorder.',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ]),
                        ),
                      ),

                      // ── Reorderable list as a sliver ──
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        sliver: SliverReorderableList(
                          itemCount: state.exercises.length,
                          onReorder: (oldIndex, newIndex) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(
                                  createEditRoutineProvider(
                                          existingRoutine)
                                      .notifier,
                                )
                                .reorderExercises(
                                    oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final re = state.exercises[index];
                            return ReorderableDragStartListener(
                              key: ValueKey(
                                  re.exerciseId + index.toString()),
                              index: index,
                              child: _EditableExerciseCard(
                                index: index,
                                routineExercise: re,
                                existingRoutine: existingRoutine,
                                onRemove: () => ref
                                    .read(
                                      createEditRoutineProvider(
                                              existingRoutine)
                                          .notifier,
                                    )
                                    .removeExercise(index),
                                onUpdate: (updated) => ref
                                    .read(
                                      createEditRoutineProvider(
                                              existingRoutine)
                                          .notifier,
                                    )
                                    .updateExercise(index, updated),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Add exercise button + bottom padding ──
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            20, 12, 20, 40),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _showExercisePicker(
                                      context, ref),
                              icon: const Icon(Icons.add_rounded),
                              label:
                                  const Text('Add Exercise'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(
                                    double.infinity, 48),
                                side: BorderSide(
                                    color: colorScheme.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
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
                      child: Text(existingRoutine != null
                          ? 'Save Changes'
                          : 'Create Routine'),
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

  Future<void> _showExercisePicker(
      BuildContext context, WidgetRef ref) async {
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ExercisePickerSheet(),
    );

    if (selected == null) return;

    final re = RoutineExercise(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      routineId: existingRoutine?.id ?? '',
      exerciseId: selected.id,
      sortOrder: 0,
      targetSets: 3,
      targetReps: 10,
      targetWeight: null,
      targetWeightUnit: 'lbs',
      notes: null,
      exercise: selected,
    );

    ref
        .read(createEditRoutineProvider(existingRoutine).notifier)
        .addExercise(re);
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(
        createEditRoutineProvider(existingRoutine).notifier);

    try {
      await notifier.save(existingRoutine?.id);
      // Force a full network refresh so the new routine appears in the list.
      await ref.read(routineListProvider.notifier).refresh();
      // Clear the form state.
      ref.invalidate(
          createEditRoutineProvider(existingRoutine));
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save routine.')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editable exercise card
// ─────────────────────────────────────────────────────────────────────────────

class _EditableExerciseCard extends StatefulWidget {
  const _EditableExerciseCard({
    required this.index,
    required this.routineExercise,
    required this.existingRoutine,
    required this.onRemove,
    required this.onUpdate,
  });

  final int index;
  final RoutineExercise routineExercise;
  final Routine? existingRoutine;
  final VoidCallback onRemove;
  final ValueChanged<RoutineExercise> onUpdate;

  @override
  State<_EditableExerciseCard> createState() =>
      _EditableExerciseCardState();
}

class _EditableExerciseCardState
    extends State<_EditableExerciseCard> {
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
        text: '${widget.routineExercise.targetSets}');
    _repsController = TextEditingController(
        text: '${widget.routineExercise.targetReps}');
    _weightController = TextEditingController(
      text: widget.routineExercise.targetWeight != null
          ? widget.routineExercise.targetWeight!.toStringAsFixed(1)
          : '',
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final sets = int.tryParse(_setsController.text) ?? 3;
    final reps = int.tryParse(_repsController.text) ?? 10;
    final weight = double.tryParse(_weightController.text);
    widget.onUpdate(widget.routineExercise.copyWith(
      targetSets: sets,
      targetReps: reps,
      targetWeight: weight,
      clearWeight: weight == null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ex = widget.routineExercise.exercise;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.fromLTRB(14, 4, 8, 4),
            leading: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${widget.index + 1}',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(
              ex?.name ?? widget.routineExercise.exerciseId,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              '${widget.routineExercise.targetSets}×${widget.routineExercise.targetReps}'
              '${widget.routineExercise.targetWeight != null ? ' @ ${widget.routineExercise.targetWeight!.toStringAsFixed(1)} ${widget.routineExercise.targetWeightUnit}' : ''}',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _expanded = !_expanded),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  onPressed: widget.onRemove,
                ),
                // Drag handle — tapping this starts the drag.
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(
                    Icons.drag_handle_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _SmallField(
                      label: 'Sets',
                      controller: _setsController,
                      onChanged: (_) => _save(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallField(
                      label: 'Reps',
                      controller: _repsController,
                      onChanged: (_) => _save(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallField(
                      label: 'Weight',
                      controller: _weightController,
                      onChanged: (_) => _save(),
                      hint: 'Optional',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  const _SmallField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint,
  });
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          style:
              textTheme.bodyMedium?.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint ?? '0',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: colorScheme.outline),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exercise picker sheet — now with filters
// ─────────────────────────────────────────────────────────────────────────────

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet();

  @override
  ConsumerState<_ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState
    extends ConsumerState<_ExercisePickerSheet> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Use the shared filtered provider so filter sheet works.
    final exercises = ref.watch(filteredExercisesProvider);
    final filters = ref.watch(exerciseFiltersProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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

              // ── Search + filter button ──
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => ref
                            .read(searchQueryProvider.notifier)
                            .update(v),
                        decoration: InputDecoration(
                          hintText: 'Search exercises...',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                      Icons.clear_rounded,
                                      size: 18,
                                      color: colorScheme
                                          .onSurfaceVariant),
                                  onPressed: () => ref
                                      .read(searchQueryProvider
                                          .notifier)
                                      .clear(),
                                )
                              : null,
                          filled: true,
                          fillColor:
                              colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Filter button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ExerciseFilterSheet.show(context);
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 150),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: filters.hasActiveFilters
                              ? AppColors.primary
                              : colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: filters.hasActiveFilters
                                ? AppColors.primary
                                : colorScheme.outline,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.tune_rounded,
                                size: 22,
                                color: filters.hasActiveFilters
                                    ? Colors.white
                                    : colorScheme
                                        .onSurfaceVariant),
                            if (filters.hasActiveFilters)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration:
                                      const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${filters.activeCount}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight:
                                            FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Active filter pills ──
              if (filters.hasActiveFilters) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    children: [
                      if (filters.stretchesOnly)
                        _FilterPill(
                          label: 'Stretches Only',
                          onRemove: () => ref
                              .read(exerciseFiltersProvider
                                  .notifier)
                              .setStretchesOnly(false),
                        ),
                      if (filters.muscle != null) ...[
                        if (filters.stretchesOnly)
                          const SizedBox(width: 8),
                        _FilterPill(
                          label: filters.muscle!,
                          onRemove: () => ref
                              .read(exerciseFiltersProvider
                                  .notifier)
                              .setMuscle(null),
                        ),
                      ],
                      if (filters.equipment != null) ...[
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: filters.equipment!,
                          onRemove: () => ref
                              .read(exerciseFiltersProvider
                                  .notifier)
                              .setEquipment(null),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // ── Exercise count ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${exercises.length} exercise${exercises.length != 1 ? 's' : ''}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: exercises.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises found.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final ex = exercises[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              ex.name,
                              style: textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              ex.muscleGroups.isNotEmpty
                                  ? ex.muscleGroups.first
                                  : '',
                              style: textTheme.labelSmall
                                  ?.copyWith(
                                color: colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).pop(ex);
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

class _FilterPill extends StatelessWidget {
  const _FilterPill(
      {required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              )),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRemove();
            },
            child: const Icon(Icons.close_rounded,
                size: 13, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}