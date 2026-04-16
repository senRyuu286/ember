import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/splash_repository_impl.dart';
import '../../domain/repositories/splash_repository.dart';
import '../../domain/usecases/get_splash_tagline_usecase.dart';

final splashRepositoryProvider = Provider<ISplashRepository>((ref) {
  return SplashRepositoryImpl();
});

final getSplashTaglineUseCaseProvider = Provider<GetSplashTaglineUseCase>((ref) {
  return GetSplashTaglineUseCase(ref.watch(splashRepositoryProvider));
});

final splashTaglineProvider = Provider<String>((ref) {
  return ref.watch(getSplashTaglineUseCaseProvider).execute();
});
