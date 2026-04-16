import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/burn_status_dto.dart';
import '../models/history_session_dto.dart';

class HistoryRemoteDataSource {
  final SupabaseClient _client;

  HistoryRemoteDataSource(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<HistorySessionDto>> getSessionsForDate(
    String userId,
    DateTime date,
  ) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final response = await _client
        .from('workout_sessions')
        .select(
          'id, user_id, routine_id, routine_name, '
          'total_volume_lbs, duration_seconds, started_at, ended_at',
        )
        .eq('user_id', userId)
        .gte('started_at', dayStart.toIso8601String())
        .lt('started_at', dayEnd.toIso8601String())
        .order('started_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(HistorySessionDto.fromSupabase).toList();
  }

  Future<List<HistorySessionDto>> getSessionsForWeek(
    String userId,
    DateTime monday,
  ) async {
    final sunday = monday.add(const Duration(days: 6));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = DateTime(
      sunday.year,
      sunday.month,
      sunday.day,
    ).add(const Duration(days: 1));

    final response = await _client
        .from('workout_sessions')
        .select(
          'id, user_id, routine_id, routine_name, '
          'total_volume_lbs, duration_seconds, started_at, ended_at',
        )
        .eq('user_id', userId)
        .gte('started_at', weekStart.toIso8601String())
        .lt('started_at', weekEnd.toIso8601String());

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(HistorySessionDto.fromSupabase).toList();
  }

  Future<Map<String, BurnStatusDto>> getBurnStatusesForWeek(
    String userId,
    DateTime monday,
  ) async {
    final sunday = monday.add(const Duration(days: 6));

    final response = await _client
        .from('weekly_burn')
        .select('burn_date, status')
        .eq('user_id', userId)
        .gte('burn_date', _dateString(monday))
        .lte('burn_date', _dateString(sunday));

    final rows = List<Map<String, dynamic>>.from(response as List);
    final map = <String, BurnStatusDto>{};
    for (final row in rows) {
      final date = row['burn_date'] as String;
      final status = row['status'] as String? ?? 'inactive';
      map[date] = BurnStatusDtoX.fromRaw(status);
    }
    return map;
  }

  String _dateString(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
