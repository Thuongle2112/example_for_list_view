import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/image_bloc.dart';

class ImageListViewPage extends StatelessWidget {
  const ImageListViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView Demo')),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ImageLoaded) {
            return ListView.builder(
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final img = state.images[index];
                return Card(
                  child: Column(
                    children: [
                      Image.network(img.downloadUrl, height: 150, fit: BoxFit.cover),
                      ListTile(title: Text(img.author)),
                    ],
                  ),
                );
              },
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