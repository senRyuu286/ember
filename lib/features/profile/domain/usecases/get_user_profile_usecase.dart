import '../../data/profile_models.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final IProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<UserProfile?> getCached() {
    return _repository.getCachedProfile();
  }

  Future<UserProfile?> sync() {
    return _repository.getRemoteProfile();
  }

  Future<void> upsertCache(UserProfile profile) {
    return _repository.upsertCachedProfile(profile);
  }
}
