import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ember/features/auth/providers/auth_provider.dart';
import 'package:ember/features/profile/data/profile_models.dart';
import 'package:ember/features/profile/providers/profile_provider.dart';

import '../../data/datasources/history_local_data_source.dart';
import '../../data/datasources/history_remote_data_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/get_day_sessions_usecase.dart';
import '../../domain/usecases/get_week_burn_status_usecase.dart';
import '../../domain/usecases/get_week_summary_usecase.dart';
import '../state/history_view_state.dart';

final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSource(ref.watch(supabaseProvider));
});

final historyLocalDataSourceProvider = Provider<HistoryLocalDataSource>((ref) {
  return HistoryLocalDataSource(ref.watch(appDatabaseProvider));
});

final historyRepositoryProvider = Provider<IHistoryRepository>((ref) {
  return HistoryRepositoryImpl(
    remote: ref.watch(historyRemoteDataSourceProvider),
    local: ref.watch(historyLocalDataSourceProvider),
  );
});

final getDaySessionsUseCaseProvider = Provider<GetDaySessionsUseCase>((ref) {
  return GetDaySessionsUseCase(ref.watch(historyRepositoryProvider));
});

final getWeekBurnStatusUseCaseProvider = Provider<GetWeekBurnStatusUseCase>((ref) {
  return GetWeekBurnStatusUseCase(ref.watch(historyRepositoryProvider));
});

final getWeekSummaryUseCaseProvider = Provider<GetWeekSummaryUseCase>((ref) {
  return GetWeekSummaryUseCase(ref.watch(historyRepositoryProvider));
});

final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryViewState>(
  HistoryController.new,
);

class HistoryController extends Notifier<HistoryViewState> {
  @override
  HistoryViewState build() {
    final todayDate = HistoryViewState.normalizeDate(DateTime.now());
    final initialState = HistoryViewState.initial(todayDate);

    ref.listen(currentUserProvider, (_, _) {
      unawaited(_reloadAll());
    });

    ref.listen(userProfileProvider, (_, next) {
      _applyProfile(next.asData?.value);
    });

    Future.microtask(() async {
      _applyProfile(ref.read(userProfileProvider).asData?.value);
      await _reloadAll();
    });

    return initialState;
  }

  Future<void> goToPreviousWeek() async {
    final nextMonday = state.selectedWeekMonday.subtract(const Duration(days: 7));
    if (nextMonday.isBefore(state.earliestMonday)) return;

    state = state.copyWith(selectedWeekMonday: nextMonday);
    await _loadWeekData();
  }

  Future<void> goToNextWeek() async {
    final nextMonday = state.selectedWeekMonday.add(const Duration(days: 7));
    if (nextMonday.isAfter(state.todayDate)) return;

    state = state.copyWith(selectedWeekMonday: nextMonday);
    await _loadWeekData();
  }

  Future<void> selectDay(DateTime day) async {
    final normalized = HistoryViewState.normalizeDate(day);
    if (normalized.isAfter(state.todayDate)) return;

    state = state.copyWith(selectedDay: normalized);
    await _loadDaySessions();
  }

  void _applyProfile(UserProfile? profile) {
    final createdAt = profile?.createdAt;
    final createdDate = createdAt != null
        ? HistoryViewState.normalizeDate(createdAt)
        : state.todayDate;

    final unitValue = profile?.unitSystem.value;
    final useKg = unitValue == 'kg_km';

    state = state.copyWith(
      useKg: useKg,
      earliestMonday: HistoryViewState.mondayOf(createdDate),
    );
  }

  Future<void> _reloadAll() async {
    await Future.wait([
      _loadWeekData(),
      _loadDaySessions(),
    ]);
  }

  Future<void> _loadWeekData() async {
    await _loadWeekBurnStatuses();
    await _loadWeekSummary();
  }

  Future<void> _loadWeekBurnStatuses() async {
    final useCase = ref.read(getWeekBurnStatusUseCaseProvider);
    final monday = state.selectedWeekMonday;

    state = state.copyWith(weekBurnStatuses: const AsyncLoading());

    try {
      final cached = await useCase.getCached(monday);
      state = state.copyWith(weekBurnStatuses: AsyncData(cached));
    } catch (error, stackTrace) {
      state = state.copyWith(
        weekBurnStatuses: AsyncError(error, stackTrace),
      );
    }

    try {
      final fresh = await useCase.sync(monday);
      state = state.copyWith(weekBurnStatuses: AsyncData(fresh));
    } catch (_) {}
  }

  Future<void> _loadWeekSummary() async {
    final useCase = ref.read(getWeekSummaryUseCaseProvider);
    final monday = state.selectedWeekMonday;

    state = state.copyWith(weekSummary: const AsyncLoading());

    try {
      final cached = await useCase.getCached(monday);
      state = state.copyWith(weekSummary: AsyncData(cached));
    } catch (error, stackTrace) {
      state = state.copyWith(weekSummary: AsyncError(error, stackTrace));
    }

    try {
      final fresh = await useCase.sync(monday);
      state = state.copyWith(weekSummary: AsyncData(fresh));
    } catch (_) {}
  }

  Future<void> _loadDaySessions() async {
    final useCase = ref.read(getDaySessionsUseCaseProvider);
    final selectedDay = state.selectedDay;

    state = state.copyWith(daySessions: const AsyncLoading());

    try {
      final cached = await useCase.getCached(selectedDay);
      state = state.copyWith(daySessions: AsyncData(cached));
    } catch (error, stackTrace) {
      state = state.copyWith(daySessions: AsyncError(error, stackTrace));
    }

    try {
      final fresh = await useCase.sync(selectedDay);
      state = state.copyWith(daySessions: AsyncData(fresh));
    } catch (_) {}
  }
}
