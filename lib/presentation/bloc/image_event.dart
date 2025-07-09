part of 'image_bloc.dart';

abstract class ImageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchImagesEvent extends ImageEvent {} 