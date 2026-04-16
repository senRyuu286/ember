import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_models.dart';
import '../presentation/controllers/profile_controller.dart' as controller;

final appDatabaseProvider = controller.appDatabaseProvider;

final profileRepositoryProvider = controller.profileRepositoryProvider;

final profileLocalRepositoryProvider = controller.profileLocalRepositoryProvider;

final userProfileProvider =
    AsyncNotifierProvider<controller.UserProfileNotifier, UserProfile?>(
  controller.UserProfileNotifier.new,
);
