import '../entities/history_entities.dart';
import '../repositories/history_repository.dart';

class GetWeekBurnStatusUseCase {
  final IHistoryRepository _repository;

  GetWeekBurnStatusUseCase(this._repository);

  Future<Map<String, BurnStatus>> getCached(DateTime monday) {
    return _repository.getCachedBurnStatusesForWeek(monday);
  }

  Future<Map<String, BurnStatus>> sync(DateTime monday) {
    return _repository.syncBurnStatusesForWeek(monday);
  }
}
