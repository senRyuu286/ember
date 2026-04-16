import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/plan_models.dart';
import '../presentation/state/create_edit_plan_state.dart';
import '../presentation/controllers/plan_controller.dart' as controller;

final planRepositoryProvider = controller.planRepositoryProvider;

final planListProvider =
    AsyncNotifierProvider<controller.PlanListNotifier, List<WorkoutPlanSummary>>(
  controller.PlanListNotifier.new,
);

final planDetailProvider =
    AsyncNotifierProvider.family<controller.PlanDetailNotifier, WorkoutPlan?, String>(
  controller.PlanDetailNotifier.new,
);

final createEditPlanProvider = NotifierProvider.family<
    controller.CreateEditPlanNotifier, CreateEditPlanState, WorkoutPlan?>(
  controller.CreateEditPlanNotifier.new,
);
