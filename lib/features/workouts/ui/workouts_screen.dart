import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/core/router/app_routes.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';
import 'package:ember/features/workouts/data/workout_models.dart';
import 'package:ember/features/workouts/data/plan_models.dart';
import 'package:ember/features/workouts/providers/workout_provider.dart';
import 'package:ember/features/workouts/providers/plan_provider.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() =>
      _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryOrange = AppColors.primary;
  late final TabController _tabController;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
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
                      'The Armory',
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Search ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search routines or plans...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant),
                              onPressed: _searchController.clear,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Tabs ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: _primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        colorScheme.onSurfaceVariant,
                    labelStyle: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'Routines'),
                      Tab(text: 'Plans'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Tab content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _RoutinesTab(searchQuery: _searchQuery),
                    _PlansTab(searchQuery: _searchQuery),
                  ],
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
// Routines tab
// ─────────────────────────────────────────────────────────────────────────────

class _RoutinesTab extends ConsumerWidget {
  const _RoutinesTab({required this.searchQuery});
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routineListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final profileAsync = ref.watch(userProfileProvider);
    final restTimer =
        profileAsync.asData?.value?.defaultRestTimerSeconds ?? 60;

    return routinesAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(routineListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (routines) {
        final filtered = searchQuery.isEmpty
            ? routines
            : routines
                .where((r) =>
                    r.title.toLowerCase().contains(searchQuery))
                .toList();

        final builtIns =
            filtered.where((r) => r.isBuiltIn).toList();
        final userRoutines =
            filtered.where((r) => !r.isBuiltIn).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            _ForgeButton(
              label: 'Forge New Routine',
              onTap: () => context.push(AppRoutes.createRoutine),
            ),
            const SizedBox(height: 28),

            if (userRoutines.isNotEmpty) ...[
              _SectionHeader(
                title: 'Your Ignition Plans',
                icon: Icons.local_fire_department_rounded,
                count: userRoutines.length,
              ),
              const SizedBox(height: 12),
              ...userRoutines.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RoutineCard(
                    routine: r,
                    restTimerSeconds: restTimer,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            _SectionHeader(
              title: 'Ember Built-ins',
              icon: Icons.bolt_rounded,
              count: builtIns.length,
            ),
            const SizedBox(height: 12),
            if (builtIns.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No routines found.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...builtIns.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RoutineCard(
                    routine: r,
                    restTimerSeconds: restTimer,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plans tab
// ─────────────────────────────────────────────────────────────────────────────

class _PlansTab extends ConsumerWidget {
  const _PlansTab({required this.searchQuery});
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(planListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return plansAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.invalidate(planListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (plans) {
        final filtered = searchQuery.isEmpty
            ? plans
            : plans
                .where((p) =>
                    p.title.toLowerCase().contains(searchQuery))
                .toList();

        final builtIns =
            filtered.where((p) => p.isBuiltIn).toList();
        final userPlans =
            filtered.where((p) => !p.isBuiltIn).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            _ForgeButton(
              label: 'Forge New Plan',
              onTap: () => context.push(AppRoutes.createPlan),
            ),
            const SizedBox(height: 28),

            if (userPlans.isNotEmpty) ...[
              _SectionHeader(
                title: 'Your Plans',
                icon: Icons.local_fire_department_rounded,
                count: userPlans.length,
              ),
              const SizedBox(height: 12),
              ...userPlans.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(plan: p),
                ),
              ),
              const SizedBox(height: 24),
            ],

            _SectionHeader(
              title: 'Ember Built-ins',
              icon: Icons.bolt_rounded,
              count: builtIns.length,
            ),
            const SizedBox(height: 12),
            if (builtIns.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No plans found.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...builtIns.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(plan: p),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared forge button
// ─────────────────────────────────────────────────────────────────────────────

class _ForgeButton extends StatelessWidget {
  const _ForgeButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
  });
  final String title;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
// Routine card  (now uses RoutineSummary)
// ─────────────────────────────────────────────────────────────────────────────

class _RoutineCard extends ConsumerWidget {
  const _RoutineCard({
    required this.routine,
    required this.restTimerSeconds,
  });
  final RoutineSummary routine;
  final int restTimerSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final lastPerformed = routine.lastPerformedAt;
    final duration = routine.formattedDuration(restTimerSeconds);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(
          AppRoutes.routineDetail.replaceFirst(':id', routine.id),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + badge + arrow ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    routine.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 17,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (routine.isBuiltIn)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Built-in',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                ),
              ],
            ),
            if (routine.description != null &&
                routine.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                routine.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),

            // ── Badges ──
            Row(
              children: [
                _RoutineBadge(
                  icon: Icons.timer_outlined,
                  label: duration,
                ),
                const SizedBox(width: 16),
                _RoutineBadge(
                  icon: Icons.fitness_center_rounded,
                  label: '${routine.exerciseCount} exercises',
                ),
              ],
            ),

            // ── Last performed ──
            if (lastPerformed != null) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 13,
                      color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Last: ${_formatLastPerformed(lastPerformed)}',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastPerformed(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _RoutineBadge extends StatelessWidget {
  const _RoutineBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final WorkoutPlanSummary plan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(
          AppRoutes.planDetail.replaceFirst(':id', plan.id),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: plan.isActive
                ? AppColors.primary
                : colorScheme.outline,
            width: plan.isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 17,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (plan.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Active',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (plan.isBuiltIn)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Built-in',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                ),
              ],
            ),
            if (plan.description != null &&
                plan.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                plan.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _RoutineBadge(
                  icon: Icons.calendar_month_rounded,
                  label: plan.durationLabel,
                ),
                if (plan.isActive && plan.startedAt != null) ...[
                  const SizedBox(width: 16),
                  _RoutineBadge(
                    icon: Icons.play_circle_outline_rounded,
                    label:
                        'Started ${_formatDate(plan.startedAt!)}',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}