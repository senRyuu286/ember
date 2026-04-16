enum DashboardDayState { active, rest, missed, future }

class DashboardChallenge {
  final String title;
  final String subtitle;
  final double progress;
  final String daysLeft;

  const DashboardChallenge({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.daysLeft,
  });
}

class DashboardAvailableChallenge {
  final String title;
  final String subtitle;
  final String duration;

  const DashboardAvailableChallenge({
    required this.title,
    required this.subtitle,
    required this.duration,
  });
}

class DashboardState {
  final int currentStreak;
  final int restDaysTaken;
  final DashboardChallenge? activeChallenge;
  final List<DashboardAvailableChallenge> availableChallenges;
  final List<DashboardDayState> weeklyDayStates;

  const DashboardState({
    required this.currentStreak,
    required this.restDaysTaken,
    required this.activeChallenge,
    required this.availableChallenges,
    required this.weeklyDayStates,
  });
}
