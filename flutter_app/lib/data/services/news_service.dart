import '../repositories/news_repository.dart';

class NewsService {
  NewsService({NewsRepository? repository})
    : _repository = repository ?? NewsRepository();

  final NewsRepository _repository;

  Future<List<dynamic>> getNews() => _repository.getNews();
}
