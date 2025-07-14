part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();
  @override
  List<Object?> get props => [];
}

class FetchNews extends NewsEvent {
  final String? category;
  final String? query;
  const FetchNews({this.category, this.query});
  @override
  List<Object?> get props => [category, query];
}

class SearchNews extends NewsEvent {
  final String query;
  const SearchNews(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterNews extends NewsEvent {
  final String category;
  const FilterNews(this.category);
  @override
  List<Object?> get props => [category];
} 