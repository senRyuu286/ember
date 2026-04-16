import 'package:flutter_riverpod/flutter_riverpod.dart';

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

