import '../../domain/entities/image_entity.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteDatasource remoteDatasource;

  ImageRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ImageEntity>> getImages({int page = 1, int limit = 10}) async {
    final models = await remoteDatasource.fetchImages(page: page, limit: limit);
    return models
        .map((model) => ImageEntity(
              id: model.id,
              author: model.author,
              downloadUrl: model.downloadUrl,
            ))
        .toList();
  }
} 