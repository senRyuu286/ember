import '../repositories/splash_repository.dart';

class GetSplashTaglineUseCase {
  final ISplashRepository _repository;

  GetSplashTaglineUseCase(this._repository);

  String execute() => _repository.randomTagline();
}
