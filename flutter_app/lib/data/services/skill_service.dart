import '../repositories/skill_repository.dart';

class SkillService {
  SkillService({SkillRepository? repository})
    : _repository = repository ?? SkillRepository();

  final SkillRepository _repository;

  Future<List<dynamic>> getSkills() => _repository.getSkills();
}
