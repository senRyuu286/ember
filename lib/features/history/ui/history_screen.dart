import 'package:flutter/material.dart';
import 'package:ember/core/theme/app_colors.dart';

/// HistoryScreen: Displays past workouts and a weekly/monthly overview.
/// Belongs in features/history/ui/
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color _bgColor = AppColors.lightSurfaceVariant;
  static const Color _primaryOrange = AppColors.primary;
  static const Color _surfaceColor = AppColors.lightBackground;

  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Templates", "Custom", "PRs Only"];

  // Upgraded mock data to support PRs and types
  final List<Map<String, dynamic>> _mockHistory = [
    {
      "date": "Today, 8:00 AM",
      "name": "Heavy Leg Day",
      "volume": "12,500 lbs",
      "duration": "1h 15m",
      "isPR": true,
      "type": "Custom",
    },
    {
      "date": "Yesterday, 5:30 PM",
      "name": "Upper Body Hypertrophy",
      "volume": "9,200 lbs",
      "duration": "55m",
      "isPR": false,
      "type": "Custom",
    },
    {
      "date": "Mon, Apr 6, 6:00 AM",
      "name": "Ember Push",
      "volume": "10,100 lbs",
      "duration": "1h 5m",
      "isPR": true,
      "type": "Templates",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic based on the selected chip
    final filteredHistory = _mockHistory.where((session) {
      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "PRs Only") return session["isPR"] == true;
      if (_selectedFilter == "Templates") return session["type"] == "Templates";
      if (_selectedFilter == "Custom") return session["type"] == "Custom";
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildTopBar(),
              ),

              // Summary Analytics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSummaryStats(),
              ),
              const SizedBox(height: 24),

              // Weekly View
              _buildWeekView(),
              const SizedBox(height: 32),

              // Filters & Feed Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "The Logbook",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildFilters(),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Timeline Feed List or Empty State
              if (filteredHistory.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final session = filteredHistory[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildHistoryCard(
                        date: session["date"],
                        name: session["name"],
                        volume: session["volume"],
                        duration: session["duration"],
                        isPR: session["isPR"],
                      ),
                    );
                  },
                ),

              // Bottom padding to clear bottom navigation bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Consistent Top Bar
  Widget _buildTopBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
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
          "Burn History",
          style: textTheme.displayMedium?.copyWith(
            fontSize: 28,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // 2. High-Level Analytics
  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard("Volume", "31.8k lbs", Icons.fitness_center),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Workouts", "12", Icons.bolt)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Time", "5h 20m", Icons.timer_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryOrange, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 3. Weekly Overview (Kept your design, just tweaked colors)
  Widget _buildWeekView() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    final dates = ["5", "6", "7", "8", "9", "10", "11"];
    final activeDays = [false, true, true, false, true, false, false];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final isActive = activeDays[index];
          final isToday = index == 4;

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isToday ? AppColors.darkSurface : _surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: isToday
                  ? null
                  : Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index],
                  style: textTheme.bodySmall?.copyWith(
                    color: isToday
                        ? Colors.white70
                        : colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dates[index],
                  style: textTheme.headlineMedium?.copyWith(
                    color: isToday ? Colors.white : colorScheme.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? _primaryOrange : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Filter Row
  Widget _buildFilters() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: _primaryOrange,
              backgroundColor: Colors.white70,
              showCheckmark: false,
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
    );
  }

  // 5. Individual Workout Card with PR Badge and Repeat Action
  Widget _buildHistoryCard({
    required String date,
    required String name,
    required String volume,
    required String duration,
    required bool isPR,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        // Future: go_router navigation to detailed history view
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
                Text(
                  date,
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 13,
                    color: _primaryOrange,
                  ),
                ),
                if (isPR)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "New PR",
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatBadge(Icons.fitness_center, volume),
                const SizedBox(width: 16),
                _buildStatBadge(Icons.timer_outlined, duration),
                const Spacer(),
                // Repeat Quick Action
                IconButton(
                  onPressed: () {
                    // Future: Trigger Riverpod state to load this routine and navigate to session screen
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: _bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.replay,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                  tooltip: "Repeat Burn",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 6. Beautiful Empty State
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 56,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              "No embers burning yet.",
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Complete a workout to log your progress.",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
