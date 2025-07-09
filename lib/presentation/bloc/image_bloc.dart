import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/usecases/get_images_usecase.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final GetImagesUsecase getImagesUsecase;

  ImageBloc(this.getImagesUsecase) : super(ImageInitial()) {
    on<FetchImagesEvent>((event, emit) async {
      emit(ImageLoading());
      try {
        final images = await getImagesUsecase();
        emit(ImageLoaded(images));
      } catch (e) {
        emit(ImageError(e.toString()));
      }
    });
  }
} 