import 'package:example_for_list_view/domain/repositories/image_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/image_remote_datasource.dart';
import '../../data/repositories/image_repository_impl.dart';
import '../../domain/usecases/get_images_usecase.dart';
import '../../presentation/bloc/image_bloc.dart';

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
