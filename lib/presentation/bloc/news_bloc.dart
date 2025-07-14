import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/usecases/get_news_usecase.dart';
import 'package:equatable/equatable.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetNewsUsecase getNewsUsecase;

  NewsBloc(this.getNewsUsecase) : super(NewsLoading()) {
    on<FetchNews>((event, emit) async {
      emit(NewsLoading());
      try {
        final news = await getNewsUsecase(category: event.category, query: event.query);
        emit(NewsLoaded(news));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });
    on<SearchNews>((event, emit) async {
      emit(NewsLoading());
      try {
        final news = await getNewsUsecase(query: event.query);
        emit(NewsLoaded(news));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });
    on<FilterNews>((event, emit) async {
      emit(NewsLoading());
      try {
        final news = await getNewsUsecase(category: event.category);
        emit(NewsLoaded(news));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });
  }
} 