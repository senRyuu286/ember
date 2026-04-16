import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ember/local_db/daos/plan_dao.dart';
import 'package:drift/drift.dart' show Value;
import '../../../local_db/app_database.dart';
import 'plan_models.dart';

class PlanRepository {
  final SupabaseClient _client;
  final PlanDao _planDao;

  PlanRepository(this._client, this._planDao);

  String? get _userId => _client.auth.currentUser?.id;

  // ── Plan summaries ────────────────────────────────────────────────────────

  Future<List<WorkoutPlanSummary>> getPlanSummaries() async {
    final cached = await _getCachedSummaries();
    if (cached.isNotEmpty) {
      _syncSummariesInBackground();
      return cached;
    }
    return await _fetchAndCacheSummaries();
  }

  Future<List<WorkoutPlanSummary>> _getCachedSummaries() async {
    final rows = await _planDao.getAllPlans();
    return rows.map(_rowToSummary).toList();
  }

  WorkoutPlanSummary _rowToSummary(WorkoutPlanTableData row) {
    return WorkoutPlanSummary(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      isBuiltIn: row.isBuiltIn,
      totalWeeks: row.totalWeeks,
      isActive: row.isActive,
      startedAt:
          row.startedAt != null ? DateTime.tryParse(row.startedAt!) : null,
    );
  }

  Future<List<WorkoutPlanSummary>> _fetchAndCacheSummaries() async {
    final uid = _userId;
    if (uid == null) return [];

    final response = await _client
        .from('workout_plans')
        .select()
        .or('user_id.eq.$uid,is_built_in.eq.true')
        .order('created_at', ascending: false);

    final summaries = <WorkoutPlanSummary>[];
    final planRows = <WorkoutPlanTableCompanion>[];

    for (final row in response as List) {
      final map = Map<String, dynamic>.from(row as Map);
      summaries.add(WorkoutPlanSummary(
        id: map['id'] as String,
        userId: map['user_id'] as String?,
        title: map['title'] as String,
        description: map['description'] as String?,
        isBuiltIn: (map['is_built_in'] as bool?) ?? false,
        totalWeeks: (map['total_weeks'] as int?) ?? 1,
        isActive: (map['is_active'] as bool?) ?? false,
        startedAt: map['started_at'] != null
            ? DateTime.tryParse(map['started_at'] as String)
            : null,
      ));
      planRows.add(_mapToCompanion(map));
    }

    await _planDao.upsertPlans(planRows);
    return summaries;
  }

  void _syncSummariesInBackground() {
    _fetchAndCacheSummaries().catchError((_) => <WorkoutPlanSummary>[]);
  }

  // ── Plan detail ───────────────────────────────────────────────────────────

  Future<WorkoutPlan?> getPlanDetail(String planId) async {
    final cached = await _getCachedPlanDetail(planId);
    if (cached != null) {
      _syncPlanDetailInBackground(planId);
      return cached;
    }
    return await _fetchAndCachePlanDetail(planId);
  }

  Future<WorkoutPlan?> _getCachedPlanDetail(String planId) async {
    final row = await _planDao.getPlanById(planId);
    if (row == null) return null;
    final days = await _buildDaysFromCache(planId);
    return _rowToPlan(row, days);
  }

  /// Builds plan days from local cache, resolving routine titles
  /// from the local RoutineTable so they display correctly.
  Future<List<PlanDay>> _buildDaysFromCache(String planId) async {
    final dayRows = await _planDao.getDaysForPlan(planId);
    final days = <PlanDay>[];

    for (final dayRow in dayRows) {
      final routineRows = await _planDao.getRoutinesForDay(dayRow.id);
      final routines = <PlanDayRoutineRef>[];

      for (final r in routineRows) {
        // Resolve the title from the local routine cache.
        final title = await _planDao.getRoutineTitleById(r.routineId);
        routines.add(PlanDayRoutineRef(
          id: r.id,
          planDayId: r.planDayId,
          routineId: r.routineId,
          sortOrder: r.sortOrder,
          routineTitle: title,
        ));
      }

      days.add(PlanDay(
        id: dayRow.id,
        planId: dayRow.planId,
        weekNumber: dayRow.weekNumber,
        dayOfWeek: dayRow.dayOfWeek,
        isRestDay: dayRow.isRestDay,
        label: dayRow.label,
        routines: routines,
      ));
    }
    return days;
  }

  WorkoutPlan _rowToPlan(WorkoutPlanTableData row, List<PlanDay> days) {
    return WorkoutPlan(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      isBuiltIn: row.isBuiltIn,
      totalWeeks: row.totalWeeks,
      isActive: row.isActive,
      startedAt:
          row.startedAt != null ? DateTime.tryParse(row.startedAt!) : null,
      createdAt: row.createdAt.isNotEmpty
          ? DateTime.parse(row.createdAt)
          : DateTime.now(),
      updatedAt:
          row.updatedAt != null ? DateTime.tryParse(row.updatedAt!) : null,
      days: days,
    );
  }

  Future<WorkoutPlan?> _fetchAndCachePlanDetail(String planId) async {
    final planResponse = await _client
        .from('workout_plans')
        .select()
        .eq('id', planId)
        .maybeSingle();
    if (planResponse == null) return null;

    final daysResponse = await _client
        .from('plan_days')
        .select()
        .eq('plan_id', planId)
        .order('week_number', ascending: true)
        .order('day_of_week', ascending: true);

    final planMap = Map<String, dynamic>.from(planResponse as Map);
    final days = <PlanDay>[];
    final dayCompanions = <PlanDayTableCompanion>[];
    final dayRoutineCompanions = <PlanDayRoutineTableCompanion>[];

    for (final dayRow in daysResponse as List) {
      final dayMap = Map<String, dynamic>.from(dayRow as Map);
      final dayId = dayMap['id'] as String;

      final routinesResponse = await _client
          .from('plan_day_routines')
          .select('*, routines(id, title)')
          .eq('plan_day_id', dayId)
          .order('sort_order', ascending: true);

      final routineRefs = <PlanDayRoutineRef>[];
      for (final r in routinesResponse as List) {
        final rMap = Map<String, dynamic>.from(r as Map);
        final routineMap = rMap['routines'] != null
            ? Map<String, dynamic>.from(rMap['routines'] as Map)
            : null;
        routineRefs.add(PlanDayRoutineRef(
          id: rMap['id'] as String,
          planDayId: dayId,
          routineId: rMap['routine_id'] as String,
          sortOrder: (rMap['sort_order'] as int?) ?? 0,
          routineTitle: routineMap?['title'] as String?,
        ));

        dayRoutineCompanions.add(PlanDayRoutineTableCompanion(
          id: Value(rMap['id'] as String),
          planDayId: Value(dayId),
          routineId: Value(rMap['routine_id'] as String),
          sortOrder: Value((rMap['sort_order'] as int?) ?? 0),
        ));
      }

      days.add(PlanDay.fromMap(dayMap, routines: routineRefs));

      dayCompanions.add(PlanDayTableCompanion(
        id: Value(dayId),
        planId: Value(planId),
        weekNumber: Value((dayMap['week_number'] as int?) ?? 1),
        dayOfWeek: Value((dayMap['day_of_week'] as int?) ?? 1),
        isRestDay: Value((dayMap['is_rest_day'] as bool?) ?? false),
        label: Value(dayMap['label'] as String?),
      ));
    }

    await _planDao.upsertPlanWithDays(
      plan: _mapToCompanion(planMap),
      days: dayCompanions,
      dayRoutines: dayRoutineCompanions,
    );

    return WorkoutPlan.fromMap(planMap, days: days);
  }

  void _syncPlanDetailInBackground(String planId) {
    _fetchAndCachePlanDetail(planId).catchError((_) => null as WorkoutPlan?);
  }

  // ── Plan mutations ────────────────────────────────────────────────────────

  Future<String> createPlan({
    required String title,
    String? description,
    required int totalWeeks,
    required List<PlanDay> days,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not authenticated');

    final planResponse = await _client
        .from('workout_plans')
        .insert({
          'user_id': uid,
          'title': title,
          'description': description,
          'is_built_in': false,
          'total_weeks': totalWeeks,
          'is_active': false,
        })
        .select('id')
        .single();

    final planId = planResponse['id'] as String;
    await _upsertDaysToSupabase(planId, days);
    await _planDao.deletePlanById(planId).catchError((_) async {});
    return planId;
  }

  Future<void> updatePlan({
    required String planId,
    required String title,
    String? description,
    required int totalWeeks,
    required List<PlanDay> days,
  }) async {
    await _client.from('workout_plans').update({
      'title': title,
      'description': description,
      'total_weeks': totalWeeks,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', planId);

    await _client.from('plan_days').delete().eq('plan_id', planId);
    await _upsertDaysToSupabase(planId, days);
    await _planDao.deletePlanById(planId).catchError((_) async {});
  }

  Future<void> deletePlan(String planId) async {
    await _client.from('workout_plans').delete().eq('id', planId);
    await _planDao.deletePlanById(planId).catchError((_) async {});
  }

  Future<void> activatePlan(String planId) async {
    final uid = _userId;
    if (uid == null) return;

    await _client
        .from('workout_plans')
        .update({'is_active': false, 'started_at': null})
        .eq('user_id', uid)
        .eq('is_active', true);

    final now = DateTime.now().toIso8601String();
    await _client.from('workout_plans').update({
      'is_active': true,
      'started_at': now,
    }).eq('id', planId);

    await _planDao.deletePlanById(planId).catchError((_) async {});
  }

  Future<void> deactivatePlan(String planId) async {
    await _client.from('workout_plans').update({
      'is_active': false,
      'started_at': null,
    }).eq('id', planId);
    await _planDao.deletePlanById(planId).catchError((_) async {});
  }

  Future<void> _upsertDaysToSupabase(
      String planId, List<PlanDay> days) async {
    if (days.isEmpty) return;

    final dayInserts = days
        .map((d) => {
              'plan_id': planId,
              'week_number': d.weekNumber,
              'day_of_week': d.dayOfWeek,
              'is_rest_day': d.isRestDay,
              'label': d.label,
            })
        .toList();

    final inserted = await _client
        .from('plan_days')
        .insert(dayInserts)
        .select('id, week_number, day_of_week');

    final idMap = <String, String>{};
    for (final row in inserted as List) {
      final key = '${row['week_number']}_${row['day_of_week']}';
      idMap[key] = row['id'] as String;
    }

    final routineInserts = <Map<String, dynamic>>[];
    for (final day in days) {
      if (day.isRestDay || day.routines.isEmpty) continue;
      final key = '${day.weekNumber}_${day.dayOfWeek}';
      final dayId = idMap[key];
      if (dayId == null) continue;
      for (int i = 0; i < day.routines.length; i++) {
        routineInserts.add({
          'plan_day_id': dayId,
          'routine_id': day.routines[i].routineId,
          'sort_order': i,
        });
      }
    }

    if (routineInserts.isNotEmpty) {
      await _client.from('plan_day_routines').insert(routineInserts);
    }
  }

  WorkoutPlanTableCompanion _mapToCompanion(Map<String, dynamic> map) {
    return WorkoutPlanTableCompanion(
      id: Value(map['id'] as String),
      userId: Value(map['user_id'] as String?),
      title: Value(map['title'] as String),
      description: Value(map['description'] as String?),
      isBuiltIn: Value((map['is_built_in'] as bool?) ?? false),
      totalWeeks: Value((map['total_weeks'] as int?) ?? 1),
      isActive: Value((map['is_active'] as bool?) ?? false),
      startedAt: Value(map['started_at'] as String?),
      createdAt: Value((map['created_at'] as String?) ?? ''),
      updatedAt: Value(map['updated_at'] as String?),
    );
  }

  Future<List<WorkoutPlanSummary>> forceFetchSummaries() =>
      _fetchAndCacheSummaries();
}