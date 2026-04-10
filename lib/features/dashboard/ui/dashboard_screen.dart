import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Expanded enum to distinguish between a missed day and a future day
enum DayState { active, rest, missed, future }

/// DashboardScreen: The primary entry point for Ember.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Brand Colors
  static const Color _bgColor = Color(0xFFDEE1E9);
  static const Color _primaryOrange = Color(0xFFFA4D1A);
  static const Color _surfaceColor = Color(0xFFF9FAFF);

  // Mock State
  final int _currentStreak = 5;
  final int _restDaysTaken = 1; // Max 3 per week
  
  // Active challenge state (set to null to see the "Choose one" state)
  final Map<String, dynamic> _activeChallenge = {
    "title": "4-Week Full Body",
    "subtitle": "Build foundational strength",
    "progress": 0.25,
    "daysLeft": "21 days left",
  };

  final List<Map<String, String>> _availableChallenges = [
    {"title": "14-Day Core Crusher", "subtitle": "Daily ab incinerator", "duration": "2 Weeks"},
    {"title": "Pull-Up Mastery", "subtitle": "Conquer the bar", "duration": "4 Weeks"},
    {"title": "Cardio Engine", "subtitle": "Boost your VO2 Max", "duration": "3 Weeks"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(streak: _currentStreak),
              const SizedBox(height: 32),
              _buildWeeklySummary(restDays: _restDaysTaken),
              const SizedBox(height: 32),
              _buildChallengesSection(),
              const SizedBox(height: 32),
              _buildSparkFeed(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Bar: Custom Logo, App Name, Search, Streak
  Widget _buildTopBar({required int streak}) {
    return Row(
      children: [
        // Custom Logo Asset
        Image.asset(
          'assets/logo/logo-primary@2x.png',
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) {
            // Fallback just in case asset isn't loaded yet
            return const Icon(Icons.local_fire_department, color: _primaryOrange, size: 28);
          },
        ),
        const SizedBox(width: 6),
        Text(
          "Ember",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 16),
        
        // Search Bar for Friends
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Find friends...",
                hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.black38),
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.black45),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Streak Indicator (Icon + Number only)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: _primaryOrange, size: 18),
              const SizedBox(width: 4),
              Text(
                "$streak",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Weekly Summary with Rest Days Counter
  Widget _buildWeeklySummary({required int restDays}) {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    
    // Mock data: Monday active, Tuesday missed, Wednesday active, Thursday rest, Friday-Sunday future
    final dayStates = [
      DayState.active,
      DayState.missed,  // <-- Missed day (no exercise, not a rest day)
      DayState.active,
      DayState.rest,
      DayState.future,
      DayState.future,
      DayState.future,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "The Weekly Burn",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$restDays/3 Rest Days",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final state = dayStates[index];
            
            Color boxColor;
            BoxBorder? boxBorder;
            Widget innerWidget;

            switch (state) {
              case DayState.active:
                boxColor = _primaryOrange;
                innerWidget = const Icon(Icons.check, size: 20, color: Colors.white);
                break;
              case DayState.rest:
                boxColor = Colors.black12; // Muted background for rest day
                innerWidget = Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ); // Subdued dash indicator
                break;
              case DayState.missed:
                boxColor = Colors.transparent; 
                boxBorder = Border.all(color: Colors.black12, width: 2); // Faint border
                innerWidget = const Icon(Icons.close, size: 16, color: Colors.black26); // Subtle X
                break;
              case DayState.future:
                boxColor = Colors.white70;
                innerWidget = const SizedBox.shrink();
                break;
            }

            return Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: boxColor,
                    shape: BoxShape.circle,
                    border: boxBorder,
                  ),
                  child: Center(child: innerWidget),
                ),
                const SizedBox(height: 8),
                Text(
                  days[index], 
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // 3. Challenges Section (Active + Available Carousel)
  Widget _buildChallengesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Ignition",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 16),
        
        // Top Card: Active Challenge or Empty State
        _buildActiveChallengeCard(
          title: _activeChallenge["title"],
          subtitle: _activeChallenge["subtitle"],
          progress: _activeChallenge["progress"],
          daysLeft: _activeChallenge["daysLeft"],
        ),

        const SizedBox(height: 24),
        
        // Bottom List: Side-scrollable Available Challenges
        Text(
          "The Kindling",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableChallenges.length,
            itemBuilder: (context, index) {
              final challenge = _availableChallenges[index];
              return _buildAvailableChallengeCard(
                title: challenge["title"]!,
                subtitle: challenge["subtitle"]!,
                duration: challenge["duration"]!,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveChallengeCard({
    required String title,
    required String subtitle,
    required double progress,
    required String daysLeft,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
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
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.emoji_events, color: _primaryOrange),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(_primaryOrange),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                daysLeft,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAvailableChallengeCard({
    required String title,
    required String subtitle,
    required String duration,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              duration,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 4. The Spark Feed
  Widget _buildSparkFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "The Spark Feed",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: _bgColor,
                      child: Icon(Icons.person, color: Colors.black45),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jordan ${index + 1}",
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Crushed 45m Push",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "🔥 Send Spark",
                              style: TextStyle(
                                color: _primaryOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}