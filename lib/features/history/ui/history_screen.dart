import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HistoryScreen: Displays past workouts and a weekly/monthly overview.
/// Belongs in features/history/ui/
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color _bgColor = Color(0xFFDEE1E9);
  static const Color _primaryOrange = Color(0xFFFA4D1A);
  static const Color _surfaceColor = Color(0xFFF9FAFF);

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
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
    return Row(
      children: [
        Image.asset(
          'assets/logo/logo-primary@2x.png',
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.local_fire_department, color: _primaryOrange, size: 32);
          },
        ),
        const SizedBox(width: 12),
        Text(
          "Burn History",
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
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
        Expanded(child: _buildStatCard("Volume", "31.8k lbs", Icons.fitness_center)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Workouts", "12", Icons.bolt)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Time", "5h 20m", Icons.timer_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
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
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
              color: isToday ? Colors.black87 : _surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: isToday ? null : Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index],
                  style: GoogleFonts.inter(
                    color: isToday ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dates[index],
                  style: GoogleFonts.outfit(
                    color: isToday ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.black87,
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
              color: Colors.black.withValues(alpha: 0.03),
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
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isPR)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, size: 14, color: Color(0xFFB8860B)),
                        const SizedBox(width: 4),
                        Text(
                          "New PR",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB8860B),
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
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.replay, color: Colors.black87, size: 20),
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
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 6. Beautiful Empty State
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.history_toggle_off, size: 56, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              "No embers burning yet.",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Complete a workout to log your progress.",
              style: GoogleFonts.inter(color: Colors.black38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}