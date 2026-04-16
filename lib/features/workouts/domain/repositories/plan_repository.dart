import '../../data/plan_models.dart';

abstract class IPlanRepository {
  Future<List<WorkoutPlanSummary>> getPlanSummaries();
  Future<List<WorkoutPlanSummary>> forceFetchSummaries();
  Future<WorkoutPlan?> getPlanDetail(String planId);

  Future<String> createPlan({
    required String title,
    String? description,
    required int totalWeeks,
    required List<PlanDay> days,
  });

  Future<void> updatePlan({
    required String planId,
    required String title,
    String? description,
    required int totalWeeks,
    required List<PlanDay> days,
  });

  Future<void> deletePlan(String planId);
  Future<void> activatePlan(String planId);
  Future<void> deactivatePlan(String planId);
}
