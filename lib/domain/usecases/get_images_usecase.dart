import '../entities/image_entity.dart';
import '../repositories/image_repository.dart';

class GetImagesUsecase {
  final ImageRepository repository;

  GetImagesUsecase(this.repository);

  Future<List<ImageEntity>> call({int page = 1, int limit = 10}) async {
    return await repository.getImages(page: page, limit: limit);
  }
} 