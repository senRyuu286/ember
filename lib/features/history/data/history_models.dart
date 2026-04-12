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

  /// Formatted volume string respecting the user's unit system.
  String formattedVolume({required bool useKg}) {
    final volume = useKg ? totalVolumeLbs * 0.453592 : totalVolumeLbs;
    final unit = useKg ? 'kg' : 'lbs';
    if (volume >= 1000) {
      final k = volume / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k $unit';
    }
    return '${volume.toStringAsFixed(0)} $unit';
  }

  /// Formatted duration string (e.g. "1h 15m" or "45m").
  String get formattedDuration {
    if (durationSeconds == null || durationSeconds == 0) return '--';
    final h = durationSeconds! ~/ 3600;
    final m = (durationSeconds! % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  factory WorkoutSession.fromSupabase(Map<String, dynamic> map) {
    final startedAt = DateTime.parse(map['started_at'] as String);
    final rawName = map['routine_name'] as String?;

    return WorkoutSession(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      routineId: map['routine_id'] as String?,
      displayName: (rawName != null && rawName.isNotEmpty)
          ? rawName
          : _generateName(startedAt),
      totalVolumeLbs: (map['total_volume_lbs'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: map['duration_seconds'] as int?,
      startedAt: startedAt,
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
    );
  }

  static String _generateName(DateTime date) {
    final hour = date.hour;
    if (hour < 12) return 'Morning Burn';
    if (hour < 17) return 'Afternoon Burn';
    return 'Evening Burn';
  }
}

class DayBurnStatus {
  final DateTime date;
  final BurnStatus status;

  const DayBurnStatus({required this.date, required this.status});
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
