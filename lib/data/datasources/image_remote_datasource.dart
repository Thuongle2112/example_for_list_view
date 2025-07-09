import 'package:dio/dio.dart';
import '../models/image_model.dart';

class ImageRemoteDatasource {
  final Dio dio;

  ImageRemoteDatasource(this.dio);

  Future<List<ImageModel>> fetchImages() async {
    final response = await dio.get('https://picsum.photos/v2/list');
    return (response.data as List)
        .map((json) => ImageModel.fromJson(json))
        .toList();
  }
} 