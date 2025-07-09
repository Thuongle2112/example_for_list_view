import '../../domain/entities/image_entity.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteDatasource remoteDatasource;

  ImageRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ImageEntity>> getImages() async {
    final models = await remoteDatasource.fetchImages();
    return models
        .map((model) => ImageEntity(
              id: model.id,
              author: model.author,
              downloadUrl: model.downloadUrl,
            ))
        .toList();
  }
} 