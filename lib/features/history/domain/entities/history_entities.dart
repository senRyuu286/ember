enum BurnStatus { workoutDone, restDay, inactive }

class WorkoutSession {
  final String id;
  final String userId;
  final String? routineId;
  final String displayName;
  final double totalVolumeLbs;
  final int? durationSeconds;
  final DateTime startedAt;
  final DateTime? endedAt;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.displayName,
    required this.totalVolumeLbs,
    required this.durationSeconds,
    required this.startedAt,
    required this.endedAt,
  });

  String formattedVolume({required bool useKg}) {
    final volume = useKg ? totalVolumeLbs * 0.453592 : totalVolumeLbs;
    final unit = useKg ? 'kg' : 'lbs';
    if (volume >= 1000) {
      final k = volume / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k $unit';
    }
    return '${volume.toStringAsFixed(0)} $unit';
  }

  String get formattedDuration {
    if (durationSeconds == null || durationSeconds == 0) return '--';
    final h = durationSeconds! ~/ 3600;
    final m = (durationSeconds! % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class WeekSummary {
  final int totalWorkouts;
  final double totalVolumeLbs;
  final int totalDurationSeconds;

  const WeekSummary({
    required this.totalWorkouts,
    required this.totalVolumeLbs,
    required this.totalDurationSeconds,
  });

  factory WeekSummary.fromSessions(List<WorkoutSession> sessions) {
    return WeekSummary(
      totalWorkouts: sessions.length,
      totalVolumeLbs: sessions.fold(0.0, (sum, s) => sum + s.totalVolumeLbs),
      totalDurationSeconds: sessions.fold(
        0,
        (sum, s) => sum + (s.durationSeconds ?? 0),
      ),
    );
  }

  String formattedVolume({required bool useKg}) {
    final volume = useKg ? totalVolumeLbs * 0.453592 : totalVolumeLbs;
    final unit = useKg ? 'kg' : 'lbs';
    if (volume >= 1000) {
      final k = volume / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k $unit';
    }
    return '${volume.toStringAsFixed(0)} $unit';
  }

  String get formattedDuration {
    final h = totalDurationSeconds ~/ 3600;
    final m = (totalDurationSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
