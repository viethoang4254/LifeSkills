import '../../utils/auth_manager.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  AuthService({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  Future<bool> login({required String email, required String password}) async {
    final user = await _authRepository.login(email: email, password: password);
    await AuthManager.saveUser(user);
    return AuthManager.shouldShowFirstLoginOnboarding();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authRepository.register(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<void> logout() => AuthManager.logout();
}
