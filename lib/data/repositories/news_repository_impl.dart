import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDatasource remoteDatasource;

  NewsRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<NewsArticle>> getTopHeadlines({String? category, String? query}) async {
    final models = await remoteDatasource.getTopHeadlines(category: category, query: query);
    return models.map((e) => e.toEntity()).toList();
  }
} 