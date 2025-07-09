import '../entities/image_entity.dart';
import '../repositories/image_repository.dart';

class GetImagesUsecase {
  final ImageRepository repository;

  GetImagesUsecase(this.repository);

  Future<List<ImageEntity>> call() async {
    return await repository.getImages();
  }
} 