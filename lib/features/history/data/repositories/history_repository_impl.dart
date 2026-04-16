import '../../domain/entities/history_entities.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../datasources/history_remote_data_source.dart';
import '../models/burn_status_dto.dart';
import '../models/history_session_dto.dart';

class HistoryRepositoryImpl implements IHistoryRepository {
  final HistoryRemoteDataSource _remote;
  final HistoryLocalDataSource _local;

  HistoryRepositoryImpl({
    required HistoryRemoteDataSource remote,
    required HistoryLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  @override
  Future<List<WorkoutSession>> getCachedSessionsForDate(DateTime date) async {
    final userId = _remote.currentUserId;
    if (userId == null) return [];

    final localSessions = await _local.getSessionsForDate(userId, date);
    return localSessions.map(_mapSession).toList();
  }

  @override
  Future<List<WorkoutSession>> syncSessionsForDate(DateTime date) async {
    final userId = _remote.currentUserId;
    if (userId == null) return [];

    final remoteSessions = await _remote.getSessionsForDate(userId, date);
    await _local.upsertSessions(remoteSessions);

    final localSessions = await _local.getSessionsForDate(userId, date);
    return localSessions.map(_mapSession).toList();
  }

  @override
  Future<List<WorkoutSession>> getCachedSessionsForWeek(DateTime monday) async {
    final userId = _remote.currentUserId;
    if (userId == null) return [];

    final localSessions = await _local.getSessionsForWeek(userId, monday);
    return localSessions.map(_mapSession).toList();
  }

  @override
  Future<List<WorkoutSession>> syncSessionsForWeek(DateTime monday) async {
    final userId = _remote.currentUserId;
    if (userId == null) return [];

    final remoteSessions = await _remote.getSessionsForWeek(userId, monday);
    await _local.upsertSessions(remoteSessions);

    final localSessions = await _local.getSessionsForWeek(userId, monday);
    return localSessions.map(_mapSession).toList();
  }

  @override
  Future<Map<String, BurnStatus>> getCachedBurnStatusesForWeek(
    DateTime monday,
  ) async {
    final userId = _remote.currentUserId;
    if (userId == null) return {};

    final localStatuses = await _local.getBurnStatusesForWeek(userId, monday);
    return localStatuses.map((key, value) => MapEntry(key, _mapStatus(value)));
  }

  @override
  Future<Map<String, BurnStatus>> syncBurnStatusesForWeek(DateTime monday) async {
    final userId = _remote.currentUserId;
    if (userId == null) return {};

    final remoteStatuses = await _remote.getBurnStatusesForWeek(userId, monday);
    await _local.upsertBurnStatuses(userId, remoteStatuses);

    final localStatuses = await _local.getBurnStatusesForWeek(userId, monday);
    return localStatuses.map((key, value) => MapEntry(key, _mapStatus(value)));
  }

  WorkoutSession _mapSession(HistorySessionDto dto) {
    final routineName = dto.routineName;
    final displayName = (routineName != null && routineName.isNotEmpty)
        ? routineName
        : _fallbackWorkoutName(dto.startedAt);

    return WorkoutSession(
      id: dto.id,
      userId: dto.userId,
      routineId: dto.routineId,
      displayName: displayName,
      totalVolumeLbs: dto.totalVolumeLbs,
      durationSeconds: dto.durationSeconds,
      startedAt: dto.startedAt,
      endedAt: dto.endedAt,
    );
  }

  BurnStatus _mapStatus(BurnStatusDto status) {
    switch (status) {
      case BurnStatusDto.workoutDone:
        return BurnStatus.workoutDone;
      case BurnStatusDto.restDay:
        return BurnStatus.restDay;
      case BurnStatusDto.inactive:
        return BurnStatus.inactive;
    }
  }

  String _fallbackWorkoutName(DateTime date) {
    final hour = date.hour;
    if (hour < 12) return 'Morning Burn';
    if (hour < 17) return 'Afternoon Burn';
    return 'Evening Burn';
  }
}
