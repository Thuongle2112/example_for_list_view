import 'package:equatable/equatable.dart';
import '../../domain/entities/news_article.dart';

class NewsArticleModel extends Equatable {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String source;

  const NewsArticleModel({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']?['name'] ?? '',
    );
  }

  NewsArticle toEntity() => NewsArticle(
        title: title,
        description: description,
        url: url,
        urlToImage: urlToImage,
        publishedAt: publishedAt,
        source: source,
      );

  @override
  List<Object?> get props => [title, description, url, urlToImage, publishedAt, source];
} 