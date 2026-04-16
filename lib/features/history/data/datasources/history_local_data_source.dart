import 'package:drift/drift.dart';
import 'package:ember/local_db/app_database.dart';

import '../models/burn_status_dto.dart';
import '../models/history_session_dto.dart';

class HistoryLocalDataSource {
  final AppDatabase _db;

  HistoryLocalDataSource(this._db);

  Future<List<HistorySessionDto>> getSessionsForDate(
    String userId,
    DateTime date,
  ) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final rows = await (_db.select(_db.workoutSessionTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.startedAt.isBiggerOrEqualValue(dayStart.toIso8601String()) &
                t.startedAt.isSmallerThanValue(dayEnd.toIso8601String()),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();

    return rows.map(_toSessionDto).toList();
  }

  Future<List<HistorySessionDto>> getSessionsForWeek(
    String userId,
    DateTime monday,
  ) async {
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final rows = await (_db.select(_db.workoutSessionTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.startedAt.isBiggerOrEqualValue(weekStart.toIso8601String()) &
                t.startedAt.isSmallerThanValue(weekEnd.toIso8601String()),
          ))
        .get();

    return rows.map(_toSessionDto).toList();
  }

  Future<Map<String, BurnStatusDto>> getBurnStatusesForWeek(
    String userId,
    DateTime monday,
  ) async {
    final sunday = monday.add(const Duration(days: 6));

    final rows = await (_db.select(_db.weeklyBurnTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.burnDate.isBiggerOrEqualValue(_dateString(monday)) &
                t.burnDate.isSmallerOrEqualValue(_dateString(sunday)),
          ))
        .get();

    return {
      for (final row in rows)
        row.burnDate: BurnStatusDtoX.fromRaw(row.status),
    };
  }

  Future<void> upsertSessions(List<HistorySessionDto> sessions) async {
    for (final session in sessions) {
      await _db.into(_db.workoutSessionTable).insertOnConflictUpdate(
            WorkoutSessionTableCompanion(
              id: Value(session.id),
              userId: Value(session.userId),
              routineId: Value(session.routineId),
              routineName: Value(session.routineName),
              totalVolumeLbs: Value(session.totalVolumeLbs),
              durationSeconds: Value(session.durationSeconds),
              startedAt: Value(session.startedAt.toIso8601String()),
              endedAt: Value(session.endedAt?.toIso8601String()),
            ),
          );
    }
  }

  Future<void> upsertBurnStatuses(
    String userId,
    Map<String, BurnStatusDto> statuses,
  ) async {
    for (final entry in statuses.entries) {
      await _db.into(_db.weeklyBurnTable).insertOnConflictUpdate(
            WeeklyBurnTableCompanion(
              id: Value('${userId}_${entry.key}'),
              userId: Value(userId),
              burnDate: Value(entry.key),
              status: Value(entry.value.raw),
            ),
          );
    }
  }

  HistorySessionDto _toSessionDto(WorkoutSessionTableData row) {
    return HistorySessionDto(
      id: row.id,
      userId: row.userId,
      routineId: row.routineId,
      routineName: row.routineName,
      totalVolumeLbs: row.totalVolumeLbs,
      durationSeconds: row.durationSeconds,
      startedAt: DateTime.parse(row.startedAt),
      endedAt: row.endedAt != null ? DateTime.parse(row.endedAt!) : null,
    );
  }

  String _dateString(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
