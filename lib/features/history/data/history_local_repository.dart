import 'package:drift/drift.dart';
import 'package:ember/local_db/app_database.dart';
import 'history_models.dart';

class HistoryLocalRepository {
  final AppDatabase _db;

  HistoryLocalRepository(this._db);

  Future<List<WorkoutSession>> getSessionsForDate(
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

    return rows.map(_rowToSession).toList();
  }

  Future<List<WorkoutSession>> getSessionsForWeek(
    String userId,
    DateTime monday,
  ) async {
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final rows = await (_db.select(_db.workoutSessionTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.startedAt
                    .isBiggerOrEqualValue(weekStart.toIso8601String()) &
                t.startedAt.isSmallerThanValue(weekEnd.toIso8601String()),
          ))
        .get();

    return rows.map(_rowToSession).toList();
  }

  Future<Map<String, String>> getBurnStatusesForWeek(
    String userId,
    DateTime monday,
  ) async {
    final sunday = monday.add(const Duration(days: 6));
    final rows = await (_db.select(_db.weeklyBurnTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.burnDate
                    .isBiggerOrEqualValue(_dateString(monday)) &
                t.burnDate.isSmallerOrEqualValue(_dateString(sunday)),
          ))
        .get();

    return {for (final r in rows) r.burnDate: r.status};
  }

  Future<void> upsertSessions(List<WorkoutSession> sessions) async {
    for (final s in sessions) {
      await _db.into(_db.workoutSessionTable).insertOnConflictUpdate(
            WorkoutSessionTableCompanion(
              id: Value(s.id),
              userId: Value(s.userId),
              routineId: Value(s.routineId),
              routineName: Value(s.displayName),
              totalVolumeLbs: Value(s.totalVolumeLbs),
              durationSeconds: Value(s.durationSeconds),
              startedAt: Value(s.startedAt.toIso8601String()),
              endedAt: Value(s.endedAt?.toIso8601String()),
            ),
          );
    }
  }

  Future<void> upsertBurnStatuses(
    String userId,
    Map<String, String> statuses,
  ) async {
    for (final entry in statuses.entries) {
      await _db.into(_db.weeklyBurnTable).insertOnConflictUpdate(
            WeeklyBurnTableCompanion(
              id: Value('${userId}_${entry.key}'),
              userId: Value(userId),
              burnDate: Value(entry.key),
              status: Value(entry.value),
            ),
          );
    }
  }

  WorkoutSession _rowToSession(WorkoutSessionTableData row) {
    return WorkoutSession(
      id: row.id,
      userId: row.userId,
      routineId: row.routineId,
      displayName: row.routineName ?? 'Workout',
      totalVolumeLbs: row.totalVolumeLbs,
      durationSeconds: row.durationSeconds,
      startedAt: DateTime.parse(row.startedAt),
      endedAt: row.endedAt != null ? DateTime.parse(row.endedAt!) : null,
    );
  }

  String _dateString(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}