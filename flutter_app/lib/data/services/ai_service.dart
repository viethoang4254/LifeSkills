import '../repositories/ai_repository.dart';

class AiService {
  AiService({AiRepository? repository})
    : _repository = repository ?? AiRepository();

  final AiRepository _repository;

  Future<Map<String, dynamic>> askAi(String query, String userId) =>
      _repository.askAi(query, userId);
}
