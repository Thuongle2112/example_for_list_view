import '../entities/news_article.dart';

abstract class NewsRepository {
  Future<List<NewsArticle>> getTopHeadlines({String? category, String? query});
} 