import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/core/theme/app_colors.dart';
import 'package:ember/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:ember/features/dashboard/providers/dashboard_provider.dart';

/// DashboardScreen: The primary entry point for Ember.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // Brand Colors
  static const Color _bgColor = AppColors.lightSurfaceVariant;
  static const Color _primaryOrange = AppColors.primary;
  static const Color _surfaceColor = AppColors.lightBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardStateProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, streak: state.currentStreak),
              const SizedBox(height: 32),
              _buildWeeklySummary(
                context,
                restDays: state.restDaysTaken,
                dayStates: state.weeklyDayStates,
              ),
              const SizedBox(height: 32),
              _buildChallengesSection(context, state),
              const SizedBox(height: 32),
              _buildSparkFeed(context),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Bar: Custom Logo, App Name, Search, Streak
  Widget _buildTopBar(BuildContext context, {required int streak}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Custom Logo Asset
        Image.asset(
          'assets/logo/logo-primary@2x.png',
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) {
            // Fallback just in case asset isn't loaded yet
            return const Icon(
              Icons.local_fire_department,
              color: _primaryOrange,
              size: 28,
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          "Ember",
          style: textTheme.displayMedium?.copyWith(
            fontSize: 24,
            color: colorScheme.onSurface,
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
                  color: colorScheme.shadow.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Find friends...",
                hintStyle: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
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
              const Icon(
                Icons.local_fire_department,
                color: _primaryOrange,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                "$streak",
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Weekly Summary with Rest Days Counter
  Widget _buildWeeklySummary(
    BuildContext context, {
    required int restDays,
    required List<DashboardDayState> dayStates,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final days = ["M", "T", "W", "T", "F", "S", "S"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "The Weekly Burn",
              style: textTheme.headlineSmall?.copyWith(fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$restDays/3 Rest Days",
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
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
              case DashboardDayState.active:
                boxColor = _primaryOrange;
                innerWidget = const Icon(
                  Icons.check,
                  size: 20,
                  color: Colors.white,
                );
                break;
              case DashboardDayState.rest:
                boxColor = colorScheme.onSurface.withValues(alpha: 0.12);
                innerWidget = Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ); // Subdued dash indicator
                break;
              case DashboardDayState.missed:
                boxColor = Colors.transparent;
                boxBorder = Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.6),
                  width: 2,
                );
                innerWidget = Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                );
                break;
              case DashboardDayState.future:
                boxColor = colorScheme.surface.withValues(alpha: 0.7);
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
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // 3. Challenges Section (Active + Available Carousel)
  Widget _buildChallengesSection(BuildContext context, DashboardState state) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Ignition",
          style: textTheme.headlineSmall?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Top Card: Active Challenge or Empty State
        _buildActiveChallengeCard(
          context,
          title: state.activeChallenge?.title ?? 'No Active Challenge',
          subtitle: state.activeChallenge?.subtitle ?? 'Choose one to get started',
          progress: state.activeChallenge?.progress ?? 0,
          daysLeft: state.activeChallenge?.daysLeft ?? '',
        ),

        const SizedBox(height: 24),

        // Bottom List: Side-scrollable Available Challenges
        Text(
          "The Kindling",
          style: textTheme.headlineSmall?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.availableChallenges.length,
            itemBuilder: (context, index) {
              final challenge = state.availableChallenges[index];
              return _buildAvailableChallengeCard(
                context,
                title: challenge.title,
                subtitle: challenge.subtitle,
                duration: challenge.duration,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveChallengeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double progress,
    required String daysLeft,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              const Icon(Icons.emoji_events, color: _primaryOrange),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: 13,
            ),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _primaryOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                daysLeft,
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableChallengeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String duration,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              duration,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 4. The Spark Feed
  Widget _buildSparkFeed(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "The Spark Feed",
          style: textTheme.headlineSmall?.copyWith(fontSize: 16),
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
                      child: Icon(
                        Icons.person,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jordan ${index + 1}",
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Crushed 45m Push",
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "🔥 Send Spark",
                              style: textTheme.labelMedium?.copyWith(
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
