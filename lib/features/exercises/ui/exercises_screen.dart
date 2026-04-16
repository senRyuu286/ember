import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/exercises/data/exercise_models.dart';
import 'package:ember/features/exercises/presentation/state/exercise_filters.dart';
import 'package:ember/features/exercises/providers/exercise_provider.dart';
import 'exercise_detail_sheet.dart';
import 'exercise_filter_sheet.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  static const Color _primaryOrange = AppColors.primary;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).update(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final exercisesAsync = ref.watch(exerciseListProvider);
    final filtered = ref.watch(filteredExercisesProvider);
    final filters = ref.watch(exerciseFiltersProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final strengthExercises = filtered
        .where((e) => e.category != ExerciseCategory.stretch)
        .toList();
    final stretchExercises = filtered
        .where((e) => e.category == ExerciseCategory.stretch)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildTopBar(exercisesAsync),
              ),
              const SizedBox(height: 16),

              // ── Search + filter button row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSearchField(colorScheme, searchQuery),
                    ),
                    const SizedBox(width: 10),
                    _FilterButton(activeCount: filters.activeCount),
                  ],
                ),
              ),

              // ── Active filter pills ──
              if (filters.hasActiveFilters) ...[
                const SizedBox(height: 10),
                _ActiveFilterPills(filters: filters),
              ],

              const SizedBox(height: 12),

              // ── Exercise list ──
              Expanded(
                child: exercisesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _buildErrorState(),
                  data: (_) {
                    if (filtered.isEmpty) return _buildEmptyState();
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: [
                        if (strengthExercises.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Exercises',
                            count: strengthExercises.length,
                          ),
                          const SizedBox(height: 10),
                          ...strengthExercises.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ExerciseCard(exercise: e),
                            ),
                          ),
                        ],
                        if (stretchExercises.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _SectionHeader(
                            title: 'Stretches',
                            count: stretchExercises.length,
                          ),
                          const SizedBox(height: 10),
                          ...stretchExercises.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ExerciseCard(exercise: e),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AsyncValue<List<Exercise>> exercisesAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = exercisesAsync.asData?.value.length ?? 0;

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
          'Exercise Library',
          style: textTheme.displayMedium?.copyWith(
            fontSize: 26,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$total Total',
            style: textTheme.labelMedium?.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme, String searchQuery) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filters.',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          const Text('Failed to load exercises.'),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.invalidate(exerciseListProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter button
// ─────────────────────────────────────────────────────────────────────────────

class _FilterButton extends ConsumerWidget {
  const _FilterButton({required this.activeCount});
  final int activeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasFilters = activeCount > 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ExerciseFilterSheet.show(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: hasFilters
              ? AppColors.primary
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFilters ? AppColors.primary : colorScheme.outline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 22,
              color: hasFilters
                  ? Colors.white
                  : colorScheme.onSurfaceVariant,
            ),
            if (hasFilters)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active filter pills shown below search bar
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFilterPills extends ConsumerWidget {
  const _ActiveFilterPills({required this.filters});
  final ExerciseFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final pills = <Widget>[];

    if (filters.stretchesOnly) {
      pills.add(
        _ActivePill(
          label: 'Stretches Only',
          onRemove: () => ref
              .read(exerciseFiltersProvider.notifier)
              .setStretchesOnly(false),
        ),
      );
    }
    if (filters.muscle != null) {
      pills.add(
        _ActivePill(
          label: filters.muscle!,
          onRemove: () =>
              ref.read(exerciseFiltersProvider.notifier).setMuscle(null),
        ),
      );
    }
    if (filters.equipment != null) {
      pills.add(
        _ActivePill(
          label: filters.equipment!,
          onRemove: () =>
              ref.read(exerciseFiltersProvider.notifier).setEquipment(null),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: pills.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => pills[i],
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRemove();
            },
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          title,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exercise card
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});
  final Exercise exercise;

  static const Color _primaryOrange = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ExerciseDetailSheet.show(context, exercise);
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  exercise.imageAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.fitness_center_rounded,
                    color: _primaryOrange,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 15,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (exercise.muscleGroups.isNotEmpty)
                          _SmallTag(
                            label: exercise.muscleGroups.first,
                            isPrimary: true,
                          ),
                        if (exercise.equipment.isNotEmpty)
                          _SmallTag(
                            label: exercise.equipment.first,
                            isPrimary: false,
                          ),
                        if (exercise.difficulty != null)
                          _DifficultyDot(difficulty: exercise.difficulty!),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label, required this.isPrimary});
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isPrimary ? AppColors.primary : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
      ),
    );
  }
}

class _DifficultyDot extends StatelessWidget {
  const _DifficultyDot({required this.difficulty});
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
      ),
    );
  }
}