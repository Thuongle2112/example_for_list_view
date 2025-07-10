import '../entities/image_entity.dart';

abstract class ImageRepository {
  Future<List<ImageEntity>> getImages({int page = 1, int limit = 10});
} 