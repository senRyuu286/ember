import '../../domain/repositories/splash_repository.dart';
import '../splash_repository.dart';

class SplashRepositoryImpl implements ISplashRepository {
  @override
  String randomTagline() {
    return SplashData.randomTagline();
  }
}
