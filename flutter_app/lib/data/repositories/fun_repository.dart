import '../../utils/api_service.dart';

class FunRepository {
  Future<List<dynamic>> getFun() => ApiService.getFun();
}
