import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ember/features/dashboard/ui/dashboard_screen.dart';
import 'package:ember/features/workouts/ui/workouts_screen.dart';
import 'package:ember/features/exercises/ui/exercises_screen.dart';
import 'package:ember/features/history/ui/history_screen.dart';
import 'package:ember/features/profile/ui/profile_screen.dart';

import '../../domain/entities/home_navigation.dart';

final homeDestinationsProvider = Provider<List<HomeNavDestination>>((ref) {
  return homeNavDestinations;
});

final homeScreensProvider = Provider<List<Widget>>((ref) {
  return const [
    DashboardScreen(),
    WorkoutsScreen(),
    ExercisesScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];
});

final homeCurrentIndexProvider = NotifierProvider<HomeNavigationController, int>(
  HomeNavigationController.new,
);

class HomeNavigationController extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) {
    if (index == state) return;
    state = index;
  }
}
