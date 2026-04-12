import 'package:supabase_flutter/supabase_flutter.dart';
import 'history_models.dart';

class HistoryRepository {
  final SupabaseClient _client;

  HistoryRepository(this._client);

  Future<List<WorkoutSession>> getSessionsForDate(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

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

    return (response as List)
        .map((row) => WorkoutSession.fromSupabase(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  Future<Map<String, String>> getBurnStatusesForWeek(
    DateTime monday,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};

    final sunday = monday.add(const Duration(days: 6));

    final response = await _client
        .from('weekly_burn')
        .select('burn_date, status')
        .eq('user_id', userId)
        .gte('burn_date', _dateString(monday))
        .lte('burn_date', _dateString(sunday));

    final map = <String, String>{};
    for (final row in response as List) {
      map[row['burn_date'] as String] = row['status'] as String;
    }
    return map;
  }

  Future<List<WorkoutSession>> getSessionsForWeek(DateTime monday) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

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

    return (response as List)
        .map((row) => WorkoutSession.fromSupabase(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  String _dateString(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}