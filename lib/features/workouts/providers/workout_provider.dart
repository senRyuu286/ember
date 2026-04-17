import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';

import '../data/workout_models.dart';
import '../presentation/state/create_edit_routine_state.dart';
import '../presentation/controllers/workout_controller.dart' as controller;

final workoutRepositoryProvider = controller.workoutRepositoryProvider;

final routineListProvider =
    AsyncNotifierProvider<controller.RoutineListNotifier, List<RoutineSummary>>(
  controller.RoutineListNotifier.new,
);

final routineDetailProvider =
    AsyncNotifierProvider.family<controller.RoutineDetailNotifier, Routine?, String>(
  controller.RoutineDetailNotifier.new,
);

final createEditRoutineProvider = NotifierProvider.family<
    controller.CreateEditRoutineNotifier, CreateEditRoutineState, Routine?>(
  controller.CreateEditRoutineNotifier.new,
);

final todayCompletedRoutineIdsProvider =
    FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return <String>{};

  final supabase = ref.watch(supabaseProvider);
  final now = DateTime.now();
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  try {
    final response = await supabase
        .from('workout_sessions')
        .select('routine_id, ended_at')
        .eq('user_id', user.id)
        .gte('started_at', dayStart.toIso8601String())
        .lt('started_at', dayEnd.toIso8601String());

    final completedIds = <String>{};
    for (final row in response as List) {
      final routineId = row['routine_id'] as String?;
      final endedAt = row['ended_at'] as String?;
      if (routineId != null && endedAt != null && endedAt.isNotEmpty) {
        completedIds.add(routineId);
      }
    }

    return completedIds;
  } catch (_) {
    return <String>{};
  }
});

