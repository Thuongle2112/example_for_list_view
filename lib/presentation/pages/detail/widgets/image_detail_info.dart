import 'package:flutter/material.dart';
import 'package:example_for_list_view/domain/entities/image_entity.dart';

class ImageDetailInfo extends StatelessWidget {
  final ImageEntity image;
  const ImageDetailInfo({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photographer: ${image.author}',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Image ID: ${image.id}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
