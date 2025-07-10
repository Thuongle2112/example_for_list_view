import 'package:dio/dio.dart';
import '../models/image_model.dart';

class ImageRemoteDatasource {
  final Dio dio;

  ImageRemoteDatasource(this.dio);

  Future<List<ImageModel>> fetchImages({int page = 1, int limit = 10}) async {
    try {
      print('Fetching images: page=$page, limit=$limit');
      final response = await dio.get(
        'https://picsum.photos/v2/list',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.data == null) {
        print('API returned null data for page $page');
        return [];
      }
      
      final List<dynamic> dataList = response.data as List;
      print('API returned ${dataList.length} images for page $page');
      
      final images = dataList
          .map((json) => ImageModel.fromJson(json))
          .toList();
      
      print('Parsed ${images.length} images for page $page');
      return images;
    } catch (e) {
      print('Error fetching images for page $page: $e');
      rethrow;
    }
  }
} 