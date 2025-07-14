import '../entities/news_article.dart';
import '../repositories/news_repository.dart';

class GetNewsUsecase {
  final NewsRepository repository;

  GetNewsUsecase(this.repository);

  Future<List<NewsArticle>> call({String? category, String? query}) {
    return repository.getTopHeadlines(category: category, query: query);
  }
} 