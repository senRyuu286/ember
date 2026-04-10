import 'package:flutter/material.dart';
import 'package:ember/core/theme/app_colors.dart';

/// ExercisesScreen: Displays the exercise library with search and filtering.
/// Belongs in features/exercises/ui/
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  // Brand colors
  static const Color _bgColor = AppColors.lightSurfaceVariant;
  static const Color _primaryOrange = AppColors.primary;
  static const Color _surfaceColor = AppColors.lightBackground;

  // State
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";
  String _searchQuery = "";

  // Mock filters & data
  final List<String> _filters = [
    "All",
    "Chest",
    "Back",
    "Legs",
    "Barbell",
    "Dumbbell",
  ];

  // Added "equipment" to mock data to make all filters functional
  final List<Map<String, String>> _mockExercises = [
    {"name": "Barbell Squat", "muscle": "Legs", "equipment": "Barbell"},
    {"name": "Bench Press", "muscle": "Chest", "equipment": "Barbell"},
    {"name": "Pull-up", "muscle": "Back", "equipment": "Bodyweight"},
    {"name": "Romanian Deadlift", "muscle": "Legs", "equipment": "Barbell"},
    {"name": "Dumbbell Fly", "muscle": "Chest", "equipment": "Dumbbell"},
    {"name": "Barbell Row", "muscle": "Back", "equipment": "Barbell"},
    {"name": "Dumbbell Lunge", "muscle": "Legs", "equipment": "Dumbbell"},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to calculate how many exercises belong to a specific filter
  int _getExerciseCountForFilter(String filter) {
    if (filter == "All") return _mockExercises.length;
    return _mockExercises
        .where((ex) => ex["muscle"] == filter || ex["equipment"] == filter)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    // Advanced filter logic handling both category and text search
    final filteredExercises = _mockExercises.where((ex) {
      final matchesFilter =
          _selectedFilter == "All" ||
          ex["muscle"] == _selectedFilter ||
          ex["equipment"] == _selectedFilter;
      final matchesSearch = ex["name"]!.toLowerCase().contains(_searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Top Bar
            _buildTopBar(),

            // 2. Search & Filter Bar
            _buildSearchAndFilters(),

            // 3. Categorized List (Body)
            Expanded(
              child: filteredExercises.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        100,
                      ), // Bottom padding for nav bar
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        return _buildExerciseCard(
                          name: exercise["name"]!,
                          muscle: exercise["muscle"]!,
                          equipment: exercise["equipment"]!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Custom Logo Asset
          Image.asset(
            'assets/logo/logo-primary@2x.png',
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.local_fire_department,
                color: _primaryOrange,
                size: 32,
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            "Exercise Library",
            style: textTheme.displayMedium?.copyWith(
              fontSize: 28,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Total Exercises Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_mockExercises.length} Total",
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        0,
        16,
      ), // No right padding so list scrolls to edge
      child: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search exercises...",
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips with Dynamic Counts
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                final count = _getExerciseCountForFilter(filter);

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter,
                          style: textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Pill count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$count",
                            style: textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: _primaryOrange,
                    backgroundColor: Colors.white70,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? _primaryOrange : Colors.transparent,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard({
    required String name,
    required String muscle,
    required String equipment,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.fitness_center, color: _primaryOrange),
        ),
        title: Text(
          name,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              _buildTag(muscle),
              const SizedBox(width: 8),
              _buildTag(equipment, isSubtle: true),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.lightTextDisabled,
        ),
        onTap: () {
          // Future: go_router push to exercise details screen passing the ID
        },
      ),
    );
  }

  Widget _buildTag(String text, {bool isSubtle = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSubtle
            ? Colors.black.withValues(alpha: 0.05)
            : _primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: textTheme.labelSmall?.copyWith(
          color: isSubtle ? colorScheme.onSurfaceVariant : _primaryOrange,
          fontSize: 11,
          fontWeight: FontWeight.bold,
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
            Icons.search_off,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            "No exercises found",
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search or filter.",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
