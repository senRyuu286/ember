import '../entities/history_entities.dart';
import '../repositories/history_repository.dart';

class GetDaySessionsUseCase {
  final IHistoryRepository _repository;

  GetDaySessionsUseCase(this._repository);

  Future<List<WorkoutSession>> getCached(DateTime day) {
    return _repository.getCachedSessionsForDate(day);
  }

  Future<List<WorkoutSession>> sync(DateTime day) {
    return _repository.syncSessionsForDate(day);
  }
}
