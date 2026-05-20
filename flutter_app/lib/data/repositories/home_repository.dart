import '../../utils/api_service.dart';
import '../../utils/auth_manager.dart';
import '../../utils/user_progress_manager.dart';

class HomeRepository {
  Future<Map<String, dynamic>> getUser() => AuthManager.getUser();

  Future<Map<String, dynamic>> getSummary() => UserProgressManager.getSummary();

  Future<List<dynamic>> getDailyTips() => ApiService.getFun();
}
