import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ember/features/exercises/data/exercise_models.dart';
import 'package:ember/local_db/app_database.dart';
import 'package:ember/local_db/daos/routine_dao.dart';
import 'package:drift/drift.dart' show Value;
import '../domain/repositories/workout_repository.dart';
import 'workout_models.dart';

class WorkoutRepository implements IWorkoutRepository {
  final SupabaseClient _client;
  final RoutineDao _routineDao;

  WorkoutRepository(this._client, this._routineDao);

  String? get _userId => _client.auth.currentUser?.id;

  // ── Routine summaries ─────────────────────────────────────────────────────

  /// Returns cached summaries if available, then fetches fresh data from
  /// Supabase and updates the cache. Always returns the freshest data it can.
  @override
  Future<List<RoutineSummary>> getRoutineSummaries() async {
    final cached = await _getCachedSummaries();
    if (cached.isNotEmpty) {
      // Return cache immediately but also fetch fresh in background.
      // The provider's refresh() call after mutations handles the foreground
      // refresh, so background sync here only runs on passive screen opens.
      _syncRoutineSummariesInBackground();
      return cached;
    }
    return await _fetchAndCacheRoutineSummaries();
  }

  Future<List<RoutineSummary>> _getCachedSummaries() async {
    final rows = await _routineDao.getAllRoutineSummaries();
    if (rows.isEmpty) return [];

    final summaries = <RoutineSummary>[];
    for (final row in rows) {
      final exercises = await _routineDao.getExercisesForRoutine(row.id);
      DateTime? lastPerformed;
      if (row.lastPerformedAt != null && row.lastPerformedAt!.isNotEmpty) {
        lastPerformed = DateTime.tryParse(row.lastPerformedAt!);
      }
      summaries.add(
        RoutineSummary(
          id: row.id,
          userId: row.userId,
          title: row.title,
          description: row.description,
          isBuiltIn: row.isBuiltIn,
          exerciseCount: exercises.length,
          totalSets: exercises.fold(0, (s, e) => s + e.targetSets),
          lastPerformedAt: lastPerformed,
        ),
      );
    }
    return summaries;
  }

  Future<List<RoutineSummary>> _fetchAndCacheRoutineSummaries() async {
    final uid = _userId;
    if (uid == null) return [];

    final response = await _client
        .from('routines')
        .select(
          '*, routine_exercises(*), user_routine_meta!left(last_performed_at)',
        )
        .or('user_id.eq.$uid,is_built_in.eq.true')
        .order('created_at', ascending: false);

    final summaries = <RoutineSummary>[];
    final routineCompanions = <RoutineTableCompanion>[];
    final exerciseCompanionsByRoutine =
        <String, List<RoutineExerciseTableCompanion>>{};

    for (final row in response as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final meta = (map['user_routine_meta'] as List?)?.firstOrNull;
      final lastPerformed = meta?['last_performed_at'] != null
          ? DateTime.parse(meta!['last_performed_at'] as String)
          : null;

      final rawExercises = List<Map<String, dynamic>>.from(
        map['routine_exercises'] as List,
      );
      final routineId = map['id'] as String;

      summaries.add(
        RoutineSummary(
          id: routineId,
          userId: map['user_id'] as String?,
          title: map['title'] as String,
          description: map['description'] as String?,
          isBuiltIn: (map['is_built_in'] as bool?) ?? false,
          exerciseCount: rawExercises.length,
          totalSets: rawExercises.fold<int>(
            0,
            (s, e) => s + ((e['target_sets'] as int?) ?? 3),
          ),
          lastPerformedAt: lastPerformed,
        ),
      );

      routineCompanions.add(
        RoutineTableCompanion(
          id: Value(routineId),
          userId: Value(map['user_id'] as String?),
          title: Value(map['title'] as String),
          description: Value(map['description'] as String?),
          isBuiltIn: Value((map['is_built_in'] as bool?) ?? false),
          createdAt: Value((map['created_at'] as String?) ?? ''),
          updatedAt: Value((map['updated_at'] as String?) ?? ''),
          lastPerformedAt: Value(lastPerformed?.toIso8601String()),
        ),
      );

      exerciseCompanionsByRoutine[routineId] = rawExercises.map((ex) {
        return RoutineExerciseTableCompanion(
          id: Value(ex['id'] as String),
          routineId: Value(routineId),
          exerciseId: Value(ex['exercise_id'] as String),
          sortOrder: Value((ex['sort_order'] as int?) ?? 0),
          targetSets: Value((ex['target_sets'] as int?) ?? 3),
          targetReps: Value((ex['target_reps'] as int?) ?? 10),
          targetWeight: Value((ex['target_weight'] as num?)?.toDouble()),
          targetWeightUnit: Value(
            (ex['target_weight_unit'] as String?) ?? 'lbs',
          ),
          notes: Value(ex['notes'] as String?),
        );
      }).toList();
    }

    // Write all routines and their exercises to local cache.
    for (final companion in routineCompanions) {
      await _routineDao.upsertRoutineWithExercises(
        routine: companion,
        exercises: exerciseCompanionsByRoutine[companion.id.value] ?? [],
      );
    }

    return summaries;
  }

  void _syncRoutineSummariesInBackground() {
    _fetchAndCacheRoutineSummaries().catchError((_) => <RoutineSummary>[]);
  }

  // ── Routine detail ────────────────────────────────────────────────────────

  @override
  Future<Routine?> getRoutineDetail(String routineId) async {
    final cached = await _getCachedRoutineDetail(routineId);
    if (cached != null) {
      _syncRoutineDetailInBackground(routineId);
      return cached;
    }
    return await _fetchAndCacheRoutineDetail(routineId);
  }

  Future<Routine?> _getCachedRoutineDetail(String routineId) async {
    final row = await _routineDao.getRoutineById(routineId);
    if (row == null) return null;

    final exRows = await _routineDao.getExercisesForRoutine(routineId);

    // Resolve exercise names from local exercise cache.
    final routineExercises = <RoutineExercise>[];
    for (final e in exRows) {
      final exRow = await _routineDao.getExerciseById(e.exerciseId);
      Exercise? exercise;
      if (exRow != null) {
        exercise = Exercise.fromMap({
          'id': exRow.id,
          'name': exRow.name,
          'category': exRow.category,
          'difficulty': exRow.difficulty,
          'muscle_groups': exRow.muscleGroups,
          'secondary_muscles': exRow.secondaryMuscles,
          'equipment': exRow.equipment,
          'instructions': exRow.instructions,
          'breathing_cues': exRow.breathingCues,
          'dos': exRow.dos,
          'donts': exRow.donts,
          'xp_reward': exRow.xpReward,
        });
      }
      routineExercises.add(
        RoutineExercise(
          id: e.id,
          routineId: e.routineId,
          exerciseId: e.exerciseId,
          sortOrder: e.sortOrder,
          targetSets: e.targetSets,
          targetReps: e.targetReps,
          targetWeight: e.targetWeight,
          targetWeightUnit: e.targetWeightUnit,
          notes: e.notes,
          exercise: exercise,
        ),
      );
    }

    DateTime? lastPerformed;
    if (row.lastPerformedAt != null && row.lastPerformedAt!.isNotEmpty) {
      lastPerformed = DateTime.tryParse(row.lastPerformedAt!);
    }

    return Routine(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      isBuiltIn: row.isBuiltIn,
      createdAt: row.createdAt.isNotEmpty
          ? DateTime.parse(row.createdAt)
          : DateTime.now(),
      updatedAt: row.updatedAt.isNotEmpty
          ? DateTime.tryParse(row.updatedAt)
          : null,
      exercises: routineExercises,
      lastPerformedAt: lastPerformed,
    );
  }

  Future<Routine?> _fetchAndCacheRoutineDetail(String routineId) async {
    final routineResponse = await _client
        .from('routines')
        .select()
        .eq('id', routineId)
        .maybeSingle();
    if (routineResponse == null) return null;

    final exercisesResponse = await _client
        .from('routine_exercises')
        .select('*, exercises(*)')
        .eq('routine_id', routineId)
        .order('sort_order', ascending: true);

    final uid = _userId;
    DateTime? lastPerformed;
    if (uid != null) {
      final metaResponse = await _client
          .from('user_routine_meta')
          .select('last_performed_at')
          .eq('routine_id', routineId)
          .eq('user_id', uid)
          .maybeSingle();
      if (metaResponse?['last_performed_at'] != null) {
        lastPerformed = DateTime.parse(
          metaResponse!['last_performed_at'] as String,
        );
      }
    }

    final map = Map<String, dynamic>.from(routineResponse as Map);
    final routineExercises = (exercisesResponse as List).map((row) {
      final exMap = Map<String, dynamic>.from(row as Map);
      final exerciseMap = Map<String, dynamic>.from(exMap['exercises'] as Map);
      final exercise = Exercise.fromMap(exerciseMap);
      return RoutineExercise.fromMap(exMap, exercise: exercise);
    }).toList();

    final routineCompanion = RoutineTableCompanion(
      id: Value(map['id'] as String),
      userId: Value(map['user_id'] as String?),
      title: Value(map['title'] as String),
      description: Value(map['description'] as String?),
      isBuiltIn: Value((map['is_built_in'] as bool?) ?? false),
      createdAt: Value((map['created_at'] as String?) ?? ''),
      updatedAt: Value((map['updated_at'] as String?) ?? ''),
      lastPerformedAt: Value(lastPerformed?.toIso8601String()),
    );

    final exerciseCompanions = routineExercises
        .map(
          (e) => RoutineExerciseTableCompanion(
            id: Value(e.id),
            routineId: Value(e.routineId),
            exerciseId: Value(e.exerciseId),
            sortOrder: Value(e.sortOrder),
            targetSets: Value(e.targetSets),
            targetReps: Value(e.targetReps),
            targetWeight: Value(e.targetWeight),
            targetWeightUnit: Value(e.targetWeightUnit),
            notes: Value(e.notes),
          ),
        )
        .toList();

    await _routineDao.upsertRoutineWithExercises(
      routine: routineCompanion,
      exercises: exerciseCompanions,
    );

    return Routine.fromMap(
      map,
      exercises: routineExercises,
      lastPerformedAt: lastPerformed,
    );
  }

  void _syncRoutineDetailInBackground(String routineId) {
    _fetchAndCacheRoutineDetail(routineId).catchError((_) => null as Routine?);
  }

  // ── Routine mutations ─────────────────────────────────────────────────────

  /// Creates the routine in local cache first, then syncs to Supabase.
  /// Returns the Supabase-assigned ID.
  @override
  Future<String> createRoutine({
    required String title,
    String? description,
    required List<RoutineExercise> exercises,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not authenticated');

    // Write to Supabase first to get the server-assigned UUID.
    final routineResponse = await _client
        .from('routines')
        .insert({
          'user_id': uid,
          'title': title,
          'description': description,
          'is_built_in': false,
        })
        .select('id, created_at, updated_at')
        .single();

    final routineId = routineResponse['id'] as String;
    final createdAt = (routineResponse['created_at'] as String?) ?? '';
    final updatedAt = (routineResponse['updated_at'] as String?) ?? '';

    if (exercises.isNotEmpty) {
      await _client
          .from('routine_exercises')
          .insert(
            exercises
                .asMap()
                .entries
                .map(
                  (e) => {
                    'routine_id': routineId,
                    'exercise_id': e.value.exerciseId,
                    'sort_order': e.key,
                    'target_sets': e.value.targetSets,
                    'target_reps': e.value.targetReps,
                    'target_weight': e.value.targetWeight,
                    'target_weight_unit': e.value.targetWeightUnit,
                    'notes': e.value.notes,
                  },
                )
                .toList(),
          );
    }

    // Fetch the created exercise rows to get server-assigned IDs.
    final exResponse = await _client
        .from('routine_exercises')
        .select()
        .eq('routine_id', routineId)
        .order('sort_order', ascending: true);

    // Now write to local cache with real IDs.
    final routineCompanion = RoutineTableCompanion(
      id: Value(routineId),
      userId: Value(uid),
      title: Value(title),
      description: Value(description),
      isBuiltIn: const Value(false),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastPerformedAt: const Value(null),
    );

    final exerciseCompanions = (exResponse as List).map((row) {
      final m = Map<String, dynamic>.from(row as Map);
      return RoutineExerciseTableCompanion(
        id: Value(m['id'] as String),
        routineId: Value(routineId),
        exerciseId: Value(m['exercise_id'] as String),
        sortOrder: Value((m['sort_order'] as int?) ?? 0),
        targetSets: Value((m['target_sets'] as int?) ?? 3),
        targetReps: Value((m['target_reps'] as int?) ?? 10),
        targetWeight: Value((m['target_weight'] as num?)?.toDouble()),
        targetWeightUnit: Value((m['target_weight_unit'] as String?) ?? 'lbs'),
        notes: Value(m['notes'] as String?),
      );
    }).toList();

    await _routineDao.upsertRoutineWithExercises(
      routine: routineCompanion,
      exercises: exerciseCompanions,
    );

    return routineId;
  }

  @override
  Future<void> updateRoutine({
    required String routineId,
    required String title,
    String? description,
    required List<RoutineExercise> exercises,
  }) async {
    await _client
        .from('routines')
        .update({
          'title': title,
          'description': description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', routineId);

    await _client
        .from('routine_exercises')
        .delete()
        .eq('routine_id', routineId);

    if (exercises.isNotEmpty) {
      await _client
          .from('routine_exercises')
          .insert(
            exercises
                .asMap()
                .entries
                .map(
                  (e) => {
                    'routine_id': routineId,
                    'exercise_id': e.value.exerciseId,
                    'sort_order': e.key,
                    'target_sets': e.value.targetSets,
                    'target_reps': e.value.targetReps,
                    'target_weight': e.value.targetWeight,
                    'target_weight_unit': e.value.targetWeightUnit,
                    'notes': e.value.notes,
                  },
                )
                .toList(),
          );
    }

    // Evict stale cache so next detail load re-fetches from network.
    await _routineDao.deleteRoutineById(routineId).catchError((_) async {});
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    await _client.from('routines').delete().eq('id', routineId);
    await _routineDao.deleteRoutineById(routineId).catchError((_) async {});
  }

  Future<void> updateLastPerformed(String routineId) async {
    final uid = _userId;
    if (uid == null) return;

    final now = DateTime.now();
    await _client.from('user_routine_meta').upsert({
      'user_id': uid,
      'routine_id': routineId,
      'last_performed_at': now.toIso8601String(),
    });
    await _routineDao
        .updateLastPerformed(routineId, now)
        .catchError((_) async {});
  }

  // ── Sessions ──────────────────────────────────────────────────────────────

  @override
  Future<String> startSession({
    required String routineId,
    required String routineName,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Not authenticated');

    final response = await _client
        .from('workout_sessions')
        .insert({
          'user_id': uid,
          'routine_id': routineId,
          'routine_name': routineName,
          'started_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  @override
  Future<void> finishSession({
    required String sessionId,
    required String routineId,
    required int durationSeconds,
    required double totalVolumeLbs,
    required List<LoggedSetData> loggedSets,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    await _client
        .from('workout_sessions')
        .update({
          'ended_at': DateTime.now().toIso8601String(),
          'duration_seconds': durationSeconds,
          'total_volume_lbs': totalVolumeLbs,
        })
        .eq('id', sessionId);

    if (loggedSets.isNotEmpty) {
      await _client
          .from('logged_sets')
          .insert(
            loggedSets
                .map(
                  (s) => {
                    'session_id': sessionId,
                    'exercise_id': s.exerciseId,
                    'set_number': s.setNumber,
                    'reps': s.reps,
                    'weight': s.weight,
                    'unit': s.unit,
                    'completed_at': s.completedAt.toIso8601String(),
                  },
                )
                .toList(),
          );
    }

    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await _client.from('weekly_burn').upsert({
      'user_id': uid,
      'burn_date': dateKey,
      'status': 'workout_done',
    });

    await updateLastPerformed(routineId);
  }

  // Add this public wrapper in workout_repository.dart
  /// Called by the provider after mutations to force a network refresh.
  @override
  Future<List<RoutineSummary>> forceFetchSummaries() =>
      _fetchAndCacheRoutineSummaries();
}
