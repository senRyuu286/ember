import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/controllers/home_controller.dart' as controller;

final homeDestinationsProvider = controller.homeDestinationsProvider;

final homeScreensProvider = controller.homeScreensProvider;

final homeCurrentIndexProvider =
    NotifierProvider<controller.HomeNavigationController, int>(
  controller.HomeNavigationController.new,
);

final homeNavigationControllerProvider = Provider<controller.HomeNavigationController>((ref) {
  return ref.read(homeCurrentIndexProvider.notifier);
});
