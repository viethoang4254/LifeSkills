import '../repositories/home_repository.dart';

class HomeService {
  HomeService({HomeRepository? repository})
    : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;

  Future<Map<String, dynamic>> getUser() => _repository.getUser();

  Future<Map<String, dynamic>> getSummary() => _repository.getSummary();

  Future<List<dynamic>> getDailyTips() => _repository.getDailyTips();
}
