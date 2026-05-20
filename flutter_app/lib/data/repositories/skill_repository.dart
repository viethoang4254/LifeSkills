import '../../utils/api_service.dart';

class SkillRepository {
  Future<List<dynamic>> getSkills() => ApiService.getSkills();
}
