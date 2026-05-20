import '../../utils/api_service.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return ApiService.login(email, password);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return ApiService.register(name, email, password);
  }
}
