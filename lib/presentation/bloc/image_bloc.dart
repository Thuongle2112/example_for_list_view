import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/usecases/get_images_usecase.dart';
import 'package:local_auth/local_auth.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final GetImagesUsecase getImagesUsecase;
  int _currentPage = 1;
  static const int _pageSize = 10;
  final Set<String> _loadedImageIds = <String>{};

  ImageBloc(this.getImagesUsecase) : super(ImageInitial()) {
    on<FetchImagesEvent>((event, emit) async {
      emit(ImageLoading());
      _currentPage = 1;
      _loadedImageIds.clear();
      try {
        final images = await getImagesUsecase(page: _currentPage, limit: _pageSize);
        _addImageIds(images);
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
          
          // Lọc bỏ ảnh trùng lặp
          final uniqueNewImages = newImages.where((img) => !_loadedImageIds.contains(img.id)).toList();
          _addImageIds(uniqueNewImages);
          
          if (uniqueNewImages.isEmpty) {
            // Không có ảnh mới, coi như hết dữ liệu
            emit(currentState.copyWith(hasMore: false, isLoadingMore: false));
            return;
          }
          
          final allImages = [...currentState.images, ...uniqueNewImages];
          final hasMore = uniqueNewImages.length >= _pageSize;
          
          emit(ImageLoaded(allImages, hasMore: hasMore, isLoadingMore: false));
        } catch (e) {
          _currentPage--; // Revert page on error
          emit(currentState.copyWith(isLoadingMore: false));
          // Không emit error để tránh làm mất danh sách hiện tại
          print('Error loading more images: $e');
        }
      }
    });

    on<AuthenticateForAIEvent>((event, emit) async {
      emit(AuthInProgress());
      final localAuth = LocalAuthentication();
      final bool canAuthenticate = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        emit(AuthFailure('Thiết bị không hỗ trợ sinh trắc học!'));
        return;
      }
      try {
        final bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Vui lòng xác thực để tiếp tục',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (didAuthenticate) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure('Xác thực thất bại!'));
        }
      } catch (e) {
        emit(AuthFailure('Lỗi xác thực: $e'));
      }
    });
  }
  
  void _addImageIds(List<ImageEntity> images) {
    for (final img in images) {
      _loadedImageIds.add(img.id);
    }
  }
} 