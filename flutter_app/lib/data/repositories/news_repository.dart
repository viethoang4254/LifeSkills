import '../../utils/api_service.dart';

class NewsRepository {
  Future<List<dynamic>> getNews() => ApiService.getNews();
}
