import 'package:flutter/material.dart';
import 'package:example_for_list_view/domain/entities/image_entity.dart';

class ImageDetailHeader extends StatelessWidget {
  final ImageEntity image;
  const ImageDetailHeader({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'image_${image.id}',
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            image.downloadUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error, size: 50, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
