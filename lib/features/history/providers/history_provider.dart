import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';
import '../data/history_models.dart';
import '../data/history_repository.dart';
import '../data/history_local_repository.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(supabaseProvider));
});

final historyLocalRepositoryProvider =
    Provider<HistoryLocalRepository>((ref) {
  return HistoryLocalRepository(ref.watch(appDatabaseProvider));
});

// ── Helpers ───────────────────────────────────────────────────────────────────

DateTime _mondayOf(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

// ── Week navigation ───────────────────────────────────────────────────────────

final selectedWeekMondayProvider =
    NotifierProvider<SelectedWeekMondayNotifier, DateTime>(
  SelectedWeekMondayNotifier.new,
);

class SelectedWeekMondayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => _mondayOf(DateTime.now());

  void goToPreviousWeek() {
    state = state.subtract(const Duration(days: 7));
  }

  void goToNextWeek() {
    state = state.add(const Duration(days: 7));
  }

  void setWeek(DateTime monday) {
    state = monday;
  }
}

final selectedDayProvider =
    NotifierProvider<SelectedDayNotifier, DateTime>(
  SelectedDayNotifier.new,
);

class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void selectDay(DateTime day) {
    state = DateTime(day.year, day.month, day.day);
  }
}

// ── Burn statuses for the selected week ───────────────────────────────────────

final weekBurnStatusProvider =
    AsyncNotifierProvider<WeekBurnStatusNotifier, Map<String, String>>(
  WeekBurnStatusNotifier.new,
);

class WeekBurnStatusNotifier extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    final monday = ref.watch(selectedWeekMondayProvider);
    final user = ref.watch(currentUserProvider);
    if (user == null) return {};

    final local = ref.read(historyLocalRepositoryProvider);

    // Serve local cache immediately.
    final cached = await local.getBurnStatusesForWeek(user.id, monday);

    // Sync from remote in the background.
    _syncBurnStatuses(user.id, monday);

    return cached;
  }

  Future<void> _syncBurnStatuses(String userId, DateTime monday) async {
    final remote = ref.read(historyRepositoryProvider);
    final local = ref.read(historyLocalRepositoryProvider);

    final fresh = await remote.getBurnStatusesForWeek(monday);
    await local.upsertBurnStatuses(userId, fresh);

    state = AsyncData(fresh);
  }
}

// ── Week summary stats ────────────────────────────────────────────────────────

final weekSummaryProvider =
    AsyncNotifierProvider<WeekSummaryNotifier, WeekSummary>(
  WeekSummaryNotifier.new,
);

class WeekSummaryNotifier extends AsyncNotifier<WeekSummary> {
  @override
  Future<WeekSummary> build() async {
    final monday = ref.watch(selectedWeekMondayProvider);
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const WeekSummary(
        totalWorkouts: 0,
        totalVolumeLbs: 0,
        totalDurationSeconds: 0,
      );
    }

    final local = ref.read(historyLocalRepositoryProvider);
    final cached = await local.getSessionsForWeek(user.id, monday);
    final summary = _compute(cached);

    // Background sync.
    _syncWeekSessions(user.id, monday);

    return summary;
  }

  Future<void> _syncWeekSessions(String userId, DateTime monday) async {
    final remote = ref.read(historyRepositoryProvider);
    final local = ref.read(historyLocalRepositoryProvider);

    final fresh = await remote.getSessionsForWeek(monday);
    await local.upsertSessions(fresh);

    final updated = await local.getSessionsForWeek(userId, monday);
    state = AsyncData(_compute(updated));
  }

  WeekSummary _compute(List<WorkoutSession> sessions) {
    return WeekSummary(
      totalWorkouts: sessions.length,
      totalVolumeLbs: sessions.fold(0.0, (sum, s) => sum + s.totalVolumeLbs),
      totalDurationSeconds: sessions.fold(
        0,
        (sum, s) => sum + (s.durationSeconds ?? 0),
      ),
    );
  }
}

// ── Sessions for the selected day ─────────────────────────────────────────────

final daySessionsProvider =
    AsyncNotifierProvider<DaySessionsNotifier, List<WorkoutSession>>(
  DaySessionsNotifier.new,
);

class DaySessionsNotifier extends AsyncNotifier<List<WorkoutSession>> {
  @override
  Future<List<WorkoutSession>> build() async {
    final day = ref.watch(selectedDayProvider);
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final local = ref.read(historyLocalRepositoryProvider);
    final cached = await local.getSessionsForDate(user.id, day);

    // Background sync.
    _syncDaySessions(user.id, day);

    return cached;
  }

  Future<void> _syncDaySessions(String userId, DateTime day) async {
    final remote = ref.read(historyRepositoryProvider);
    final local = ref.read(historyLocalRepositoryProvider);

    final fresh = await remote.getSessionsForDate(day);
    await local.upsertSessions(fresh);

    final updated = await local.getSessionsForDate(userId, day);
    state = AsyncData(updated);
  }
}