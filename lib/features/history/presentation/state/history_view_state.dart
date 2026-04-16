import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/history_entities.dart';

class HistoryViewState {
  final DateTime selectedWeekMonday;
  final DateTime selectedDay;
  final DateTime todayDate;
  final DateTime earliestMonday;
  final bool useKg;
  final AsyncValue<WeekSummary> weekSummary;
  final AsyncValue<Map<String, BurnStatus>> weekBurnStatuses;
  final AsyncValue<List<WorkoutSession>> daySessions;

  const HistoryViewState({
    required this.selectedWeekMonday,
    required this.selectedDay,
    required this.todayDate,
    required this.earliestMonday,
    required this.useKg,
    required this.weekSummary,
    required this.weekBurnStatuses,
    required this.daySessions,
  });

  factory HistoryViewState.initial(DateTime todayDate) {
    final monday = _mondayOf(todayDate);
    return HistoryViewState(
      selectedWeekMonday: monday,
      selectedDay: todayDate,
      todayDate: todayDate,
      earliestMonday: monday,
      useKg: false,
      weekSummary: const AsyncLoading(),
      weekBurnStatuses: const AsyncLoading(),
      daySessions: const AsyncLoading(),
    );
  }

  HistoryViewState copyWith({
    DateTime? selectedWeekMonday,
    DateTime? selectedDay,
    DateTime? todayDate,
    DateTime? earliestMonday,
    bool? useKg,
    AsyncValue<WeekSummary>? weekSummary,
    AsyncValue<Map<String, BurnStatus>>? weekBurnStatuses,
    AsyncValue<List<WorkoutSession>>? daySessions,
  }) {
    return HistoryViewState(
      selectedWeekMonday: selectedWeekMonday ?? this.selectedWeekMonday,
      selectedDay: selectedDay ?? this.selectedDay,
      todayDate: todayDate ?? this.todayDate,
      earliestMonday: earliestMonday ?? this.earliestMonday,
      useKg: useKg ?? this.useKg,
      weekSummary: weekSummary ?? this.weekSummary,
      weekBurnStatuses: weekBurnStatuses ?? this.weekBurnStatuses,
      daySessions: daySessions ?? this.daySessions,
    );
  }

  bool get canGoBack => selectedWeekMonday.isAfter(earliestMonday);

  bool get canGoForward {
    final nextMonday = selectedWeekMonday.add(const Duration(days: 7));
    return !nextMonday.isAfter(todayDate);
  }

  String get weekRangeLabel {
    final sunday = selectedWeekMonday.add(const Duration(days: 6));
    return _formatMonthYearRange(selectedWeekMonday, sunday);
  }

  String get selectedDateLabel => _formatSelectedDate(selectedDay);

  BurnStatus? get selectedDayBurnStatus {
    return weekBurnStatuses.asData?.value[selectedDateKey];
  }

  String get selectedDateKey => _dateKey(selectedDay);

  static String dateKeyFor(DateTime date) => _dateKey(date);

  static DateTime mondayOf(DateTime date) => _mondayOf(date);

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatSelectedDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[date.weekday]}, ${months[date.month - 1]} ${date.day}';
  }

  static String _formatMonthYearRange(DateTime monday, DateTime sunday) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (monday.month == sunday.month && monday.year == sunday.year) {
      return '${months[monday.month - 1]} ${monday.year}';
    }

    final startLabel = months[monday.month - 1].substring(0, 3);
    final endLabel = monday.year == sunday.year
        ? months[sunday.month - 1].substring(0, 3)
        : '${months[sunday.month - 1].substring(0, 3)} ${sunday.year}';

    return '$startLabel – $endLabel ${monday.year}';
  }

  static DateTime _mondayOf(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}
