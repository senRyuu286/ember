import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/history_entities.dart';
import '../presentation/controllers/history_controller.dart';
import '../presentation/state/history_view_state.dart';

final historyViewStateProvider = Provider<HistoryViewState>((ref) {
	return ref.watch(historyControllerProvider);
});

final historyActionsProvider = Provider<HistoryController>((ref) {
	return ref.read(historyControllerProvider.notifier);
});

final historyWeekSummaryProvider = Provider<AsyncValue<WeekSummary>>((ref) {
	return ref.watch(historyViewStateProvider).weekSummary;
});

final historyWeekBurnStatusesProvider =
		Provider<AsyncValue<Map<String, BurnStatus>>>((ref) {
	return ref.watch(historyViewStateProvider).weekBurnStatuses;
});

final historyDaySessionsProvider = Provider<AsyncValue<List<WorkoutSession>>>(
	(ref) {
		return ref.watch(historyViewStateProvider).daySessions;
	},
);