import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/usecases/get_images_usecase.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final GetImagesUsecase getImagesUsecase;
  int _currentPage = 1;
  static const int _pageSize = 10;

  ImageBloc(this.getImagesUsecase) : super(ImageInitial()) {
    on<FetchImagesEvent>((event, emit) async {
      emit(ImageLoading());
      _currentPage = 1;
      try {
        final images = await getImagesUsecase(page: _currentPage, limit: _pageSize);
        emit(ImageLoaded(images, hasMore: images.length >= _pageSize));
      } catch (e) {
        emit(ImageError(e.toString()));
      }
    });

    on<LoadMoreImages>((event, emit) async {
      if (state is ImageLoaded) {
        final currentState = state as ImageLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        
        emit(currentState.copyWith(isLoadingMore: true));
        _currentPage++;
        
        try {
          final newImages = await getImagesUsecase(page: _currentPage, limit: _pageSize);
          final allImages = [...currentState.images, ...newImages];
          final hasMore = newImages.length >= _pageSize;
          
          emit(ImageLoaded(allImages, hasMore: hasMore, isLoadingMore: false));
        } catch (e) {
          _currentPage--; // Revert page on error
          emit(currentState.copyWith(isLoadingMore: false));
          emit(ImageError(e.toString()));
        }
      }
    });
  }
} 