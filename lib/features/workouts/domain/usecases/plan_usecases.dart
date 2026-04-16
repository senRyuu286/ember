import '../../data/plan_models.dart';
import '../repositories/plan_repository.dart';

class GetPlanSummariesUseCase {
  final IPlanRepository _repository;

  GetPlanSummariesUseCase(this._repository);

  Future<List<WorkoutPlanSummary>> execute() => _repository.getPlanSummaries();

  Future<List<WorkoutPlanSummary>> refresh() => _repository.forceFetchSummaries();
}

class GetPlanDetailUseCase {
  final IPlanRepository _repository;

  GetPlanDetailUseCase(this._repository);

  Future<WorkoutPlan?> execute(String planId) {
    return _repository.getPlanDetail(planId);
  }
}

class SavePlanUseCase {
  final IPlanRepository _repository;

  SavePlanUseCase(this._repository);

  Future<String> create({
    required String title,
    String? description,
    required int totalWeeks,
    required List<PlanDay> days,
  }) {
    return _repository.createPlan(
      title: title,
      description: description,
      totalWeeks: totalWeeks,
      days: days,
    );
  }

  Future<void> update({
    required String planId,
    required String title,
    String? description,
    required int totalWeeks,
    required List<PlanDay> days,
  }) {
    return _repository.updatePlan(
      planId: planId,
      title: title,
      description: description,
      totalWeeks: totalWeeks,
      days: days,
    );
  }
}

class DeletePlanUseCase {
  final IPlanRepository _repository;

  DeletePlanUseCase(this._repository);

  Future<void> execute(String planId) {
    return _repository.deletePlan(planId);
  }
}

class ActivatePlanUseCase {
  final IPlanRepository _repository;

  ActivatePlanUseCase(this._repository);

  Future<void> execute(String planId) {
    return _repository.activatePlan(planId);
  }
}

class DeactivatePlanUseCase {
  final IPlanRepository _repository;

  DeactivatePlanUseCase(this._repository);

  Future<void> execute(String planId) {
    return _repository.deactivatePlan(planId);
  }
}
