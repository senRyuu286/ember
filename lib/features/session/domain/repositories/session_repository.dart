import '../entities/session_entities.dart';

abstract class ISessionRepository {
  Future<void> finishSession({
    required String sessionId,
    required String routineId,
    required int durationSeconds,
    required double totalVolumeLbs,
    required List<CompletedSetLog> completedSets,
  });
}
