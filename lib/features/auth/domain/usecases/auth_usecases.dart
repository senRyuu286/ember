import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final IAuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<AuthResponse> execute({
    required String email,
    required String password,
  }) {
    return _repository.signUp(email: email, password: password);
  }
}

class SignInUseCase {
  final IAuthRepository _repository;

  SignInUseCase(this._repository);

  Future<AuthResponse> execute({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}

class ForgotPasswordUseCase {
  final IAuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<void> execute({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}

class SaveProfileSetupUseCase {
  final IAuthRepository _repository;

  SaveProfileSetupUseCase(this._repository);

  Future<void> execute({
    required String username,
    required String avatarId,
    String? bio,
  }) {
    return _repository.saveProfile(
      username: username,
      avatarId: avatarId,
      bio: bio,
    );
  }
}

class GetCurrentProfileUseCase {
  final IAuthRepository _repository;

  GetCurrentProfileUseCase(this._repository);

  Future<Map<String, dynamic>?> execute() {
    return _repository.getProfile();
  }
}

class SignOutUseCase {
  final IAuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<void> execute() {
    return _repository.signOut();
  }
}
