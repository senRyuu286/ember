import 'package:flutter/material.dart';
import 'package:ember/core/theme/app_colors.dart';

/// WorkoutsScreen: Manages custom routines and built-in templates.
/// Follows the "feature-first" structure under features/workouts/ui/.
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  static const Color _bgColor = AppColors.lightSurfaceVariant;
  static const Color _primaryOrange = AppColors.primary;
  static const Color _surfaceColor = AppColors.lightBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      // Removed the fixed AppBar so the top bar scrolls with the content
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCreateRoutineButton(),
              const SizedBox(height: 36),

              _buildSectionHeader(
                "Your Ignition Plans",
                Icons.local_fire_department,
              ),
              const SizedBox(height: 16),
              _buildRoutineCard(
                title: "Upper Body Hypertrophy",
                duration: "45 min",
                exerciseCount: 6,
                targetMuscles: ["Chest", "Back", "Shoulders"],
                lastPerformed: "Yesterday",
              ),
              const SizedBox(height: 16),
              _buildRoutineCard(
                title: "Leg Day A",
                duration: "60 min",
                exerciseCount: 5,
                targetMuscles: ["Quads", "Hamstrings", "Glutes", "Calves"],
                lastPerformed: "3 days ago",
              ),

              const SizedBox(height: 40),

              _buildSectionHeader("Ember Built-ins", Icons.bolt),
              const SizedBox(height: 16),
              _buildRoutineCard(
                title: "Ember Push",
                duration: "50 min",
                exerciseCount: 6,
                targetMuscles: ["Chest", "Triceps", "Shoulders"],
              ),
              const SizedBox(height: 16),
              _buildRoutineCard(
                title: "Ember Pull",
                duration: "50 min",
                exerciseCount: 6,
                targetMuscles: ["Back", "Biceps", "Forearms"],
              ),
              const SizedBox(height: 16),
              _buildRoutineCard(
                title: "Full Body Foundation",
                duration: "75 min",
                exerciseCount: 8,
                targetMuscles: ["Full Body", "Core"],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Bar: Custom Logo and Title (Scrolls with content)
  Widget _buildTopBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        // Custom Logo Asset
        Image.asset(
          'assets/logo/logo-primary@2x.png',
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            // Fallback just in case asset isn't loaded yet
            return const Icon(
              Icons.local_fire_department,
              color: _primaryOrange,
              size: 32,
            );
          },
        ),
        const SizedBox(width: 8),
        Text(
          "The Armory",
          style: textTheme.displayMedium?.copyWith(
            fontSize: 28,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // 2. Search Bar
  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search routines & templates...",
          hintStyle: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // 3. Primary Action Button
  Widget _buildCreateRoutineButton() {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          // Future: Navigate to routine creator
        },
        icon: const Icon(
          Icons.add_circle_outline,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          "Forge New Routine",
          style: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
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

  // Section Header Helper
  Widget _buildSectionHeader(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: _primaryOrange, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.headlineLarge?.copyWith(
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // 4. Unified Custom Routine & Template Card
  Widget _buildRoutineCard({
    required String title,
    required String duration,
    required int exerciseCount,
    required List<String> targetMuscles,
    String? lastPerformed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 20,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.lightTextDisabled,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badges: Duration & Exercise Count
          Row(
            children: [
              _buildRoutineBadge(Icons.timer_outlined, duration),
              const SizedBox(width: 16),
              _buildRoutineBadge(
                Icons.fitness_center,
                "$exerciseCount exercises",
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Muscle Group Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: targetMuscles
                .map((muscle) => _buildMuscleTag(muscle))
                .toList(),
          ),

          // Conditional "Last Performed" footer
          if (lastPerformed != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1, color: _bgColor),
            ),
            Text(
              "Last performed: $lastPerformed",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Badge Helper
  Widget _buildRoutineBadge(IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Muscle Tag Helper
  Widget _buildMuscleTag(String muscle) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primaryOrange.withValues(alpha: 0.2)),
      ),
      child: Text(
        muscle,
        style: textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _primaryOrange,
        ),
      ),
    );
  }
}
