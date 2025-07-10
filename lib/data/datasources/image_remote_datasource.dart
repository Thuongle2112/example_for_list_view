import 'package:dio/dio.dart';
import '../models/image_model.dart';

class ImageRemoteDatasource {
  final Dio dio;

  ImageRemoteDatasource(this.dio);

  Future<List<ImageModel>> fetchImages({int page = 1, int limit = 10}) async {
    final response = await dio.get(
      'https://picsum.photos/v2/list',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return (response.data as List)
        .map((json) => ImageModel.fromJson(json))
        .toList();
  }
} 