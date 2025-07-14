import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article_model.dart';

abstract class NewsRemoteDatasource {
  Future<List<NewsArticleModel>> getTopHeadlines({String? category, String? query});
}

class NewsRemoteDatasourceImpl implements NewsRemoteDatasource {
  final String apiKey;

  NewsRemoteDatasourceImpl(this.apiKey);

  @override
  Future<List<NewsArticleModel>> getTopHeadlines({String? category, String? query}) async {
    final params = <String, String>{
      'apiKey': apiKey,
      'country': 'us',
    };
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (query != null && query.isNotEmpty) params['q'] = query;
    final uri = Uri.https('newsapi.org', '/v2/top-headlines', params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data['articles'] ?? [];
      return articles.map((e) => NewsArticleModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
} 