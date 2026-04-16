import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/dashboard_entities.dart';
import '../presentation/controllers/dashboard_controller.dart' as controller;

final dashboardStateProvider = Provider<DashboardState>((ref) {
  return ref.watch(controller.dashboardStateProvider);
});
