import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/image_bloc.dart';

class ImageColumnPage extends StatelessWidget {
  const ImageColumnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Column Demo')),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ImageLoaded) {
            // Cảnh báo nếu quá nhiều ảnh
            if (state.images.length > 10) {
              return const Center(
                child: Text('Column không phù hợp cho danh sách dài!'),
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: state.images.map((img) => Card(
                  child: Column(
                    children: [
                      Image.network(img.downloadUrl, height: 150, fit: BoxFit.cover),
                      ListTile(title: Text(img.author)),
                    ],
                  ),
                )).toList(),
              ),
            );
          } else if (state is ImageError) {
            return Center(child: Text('Error: \\${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
} 