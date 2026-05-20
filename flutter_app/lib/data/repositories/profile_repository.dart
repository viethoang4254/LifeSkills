import '../../utils/api_service.dart';
import '../../utils/auth_manager.dart';
import '../../utils/user_progress_manager.dart';

class ProfileRepository {
  Future<Map<String, dynamic>> getUser() => AuthManager.getUser();

  Future<Map<String, dynamic>> getSummary() => UserProgressManager.getSummary();

  Future<String> getGoal() => UserProgressManager.getGoal();

  Future<void> setGoal(String goal) => UserProgressManager.setGoal(goal);

  Future<String> uploadAvatar(String userId, String filePath) {
    return ApiService.uploadAvatar(userId, filePath);
  }

  Future<void> updateAvatar(String newUrl) => AuthManager.updateAvatar(newUrl);

  Future<void> logout() => AuthManager.logout();
}
