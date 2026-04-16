import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_entities.dart';

final dashboardStateProvider = Provider<DashboardState>((ref) {
  return const DashboardState(
    currentStreak: 5,
    restDaysTaken: 1,
    activeChallenge: DashboardChallenge(
      title: '4-Week Full Body',
      subtitle: 'Build foundational strength',
      progress: 0.25,
      daysLeft: '21 days left',
    ),
    availableChallenges: [
      DashboardAvailableChallenge(
        title: '14-Day Core Crusher',
        subtitle: 'Daily ab incinerator',
        duration: '2 Weeks',
      ),
      DashboardAvailableChallenge(
        title: 'Pull-Up Mastery',
        subtitle: 'Conquer the bar',
        duration: '4 Weeks',
      ),
      DashboardAvailableChallenge(
        title: 'Cardio Engine',
        subtitle: 'Boost your VO2 Max',
        duration: '3 Weeks',
      ),
    ],
    weeklyDayStates: [
      DashboardDayState.active,
      DashboardDayState.missed,
      DashboardDayState.active,
      DashboardDayState.rest,
      DashboardDayState.future,
      DashboardDayState.future,
      DashboardDayState.future,
    ],
  );
});
