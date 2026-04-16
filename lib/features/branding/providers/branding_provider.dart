import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/get_splash_tagline_usecase.dart';
import '../presentation/controllers/branding_controller.dart' as controller;

final splashRepositoryProvider = controller.splashRepositoryProvider;

final getSplashTaglineUseCaseProvider =
    Provider<GetSplashTaglineUseCase>((ref) {
  return ref.watch(controller.getSplashTaglineUseCaseProvider);
});

final splashTaglineProvider = controller.splashTaglineProvider;
