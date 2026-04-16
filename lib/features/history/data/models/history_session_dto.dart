class HistorySessionDto {
  final String id;
  final String userId;
  final String? routineId;
  final String? routineName;
  final double totalVolumeLbs;
  final int? durationSeconds;
  final DateTime startedAt;
  final DateTime? endedAt;

  const HistorySessionDto({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.routineName,
    required this.totalVolumeLbs,
    required this.durationSeconds,
    required this.startedAt,
    required this.endedAt,
  });

  factory HistorySessionDto.fromSupabase(Map<String, dynamic> map) {
    return HistorySessionDto(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      routineId: map['routine_id'] as String?,
      routineName: map['routine_name'] as String?,
      totalVolumeLbs: (map['total_volume_lbs'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: map['duration_seconds'] as int?,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
    );
  }
}
