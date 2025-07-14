import 'package:example_for_list_view/domain/repositories/image_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/image_remote_datasource.dart';
import '../../data/repositories/image_repository_impl.dart';
import '../../domain/usecases/get_images_usecase.dart';
import '../../presentation/bloc/image_bloc.dart';
import 'package:example_for_list_view/data/datasources/news_remote_datasource.dart';
import 'package:example_for_list_view/data/repositories/news_repository_impl.dart';
import 'package:example_for_list_view/domain/repositories/news_repository.dart';
import 'package:example_for_list_view/domain/usecases/get_news_usecase.dart';
import 'package:example_for_list_view/presentation/bloc/news_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final sl = GetIt.instance;

void init() {
  // External
  sl.registerLazySingleton(() => Dio());

  // Data sources
  sl.registerLazySingleton(() => ImageRemoteDatasource(sl()));

  // Repository
  sl.registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl(sl()));

  // Usecase
  sl.registerLazySingleton(() => GetImagesUsecase(sl()));

  // Bloc
  sl.registerFactory(() => ImageBloc(sl()));
}

void setupNewsDI(GetIt sl) {
  sl.registerLazySingleton<NewsRemoteDatasource>(() => NewsRemoteDatasourceImpl(dotenv.env['NEWS_API_KEY'] ?? ''));
  sl.registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(sl()));
  sl.registerLazySingleton<GetNewsUsecase>(() => GetNewsUsecase(sl()));
  sl.registerFactory(() => NewsBloc(sl()));
}
