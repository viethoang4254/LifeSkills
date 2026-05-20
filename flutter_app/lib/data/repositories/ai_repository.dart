import '../../utils/api_service.dart';

class AiRepository {
  Future<Map<String, dynamic>> askAi(String query, String userId) =>
      ApiService.askAi(query, userId);
}
