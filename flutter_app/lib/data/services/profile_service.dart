import '../repositories/profile_repository.dart';

class ProfileService {
  ProfileService({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  final ProfileRepository _repository;

  Future<Map<String, dynamic>> getUser() => _repository.getUser();

  Future<Map<String, dynamic>> getSummary() => _repository.getSummary();

  Future<String> getGoal() => _repository.getGoal();

  Future<void> setGoal(String goal) => _repository.setGoal(goal);

  Future<String> uploadAvatar(String userId, String filePath) {
    return _repository.uploadAvatar(userId, filePath);
  }

  Future<void> updateAvatar(String newUrl) => _repository.updateAvatar(newUrl);

  Future<void> logout() => _repository.logout();
}
