part of 'image_bloc.dart';

abstract class ImageState extends Equatable {
  @override
  List<Object> get props => [];
}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageLoaded extends ImageState {
  final List<ImageEntity> images;
  final bool hasMore;
  final bool isLoadingMore;
  
  ImageLoaded(this.images, {this.hasMore = true, this.isLoadingMore = false});
  
  ImageLoaded copyWith({
    List<ImageEntity>? images,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ImageLoaded(
      images ?? this.images,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
  
  @override
  List<Object> get props => [images, hasMore, isLoadingMore];
}

class ImageError extends ImageState {
  final String message;
  ImageError(this.message);
  @override
  List<Object> get props => [message];
} 