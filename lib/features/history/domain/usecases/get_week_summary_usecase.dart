import '../entities/history_entities.dart';
import '../repositories/history_repository.dart';

class GetWeekSummaryUseCase {
  final IHistoryRepository _repository;

  GetWeekSummaryUseCase(this._repository);

  Future<WeekSummary> getCached(DateTime monday) async {
    final sessions = await _repository.getCachedSessionsForWeek(monday);
    return WeekSummary.fromSessions(sessions);
  }

  Future<WeekSummary> sync(DateTime monday) async {
    final sessions = await _repository.syncSessionsForWeek(monday);
    return WeekSummary.fromSessions(sessions);
  }
}
