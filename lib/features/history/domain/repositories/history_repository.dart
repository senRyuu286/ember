import '../entities/history_entities.dart';

abstract class IHistoryRepository {
  Future<List<WorkoutSession>> getCachedSessionsForDate(DateTime date);

  Future<List<WorkoutSession>> syncSessionsForDate(DateTime date);

  Future<List<WorkoutSession>> getCachedSessionsForWeek(DateTime monday);

  Future<List<WorkoutSession>> syncSessionsForWeek(DateTime monday);

  Future<Map<String, BurnStatus>> getCachedBurnStatusesForWeek(DateTime monday);

  Future<Map<String, BurnStatus>> syncBurnStatusesForWeek(DateTime monday);
}
