import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../domain/entities/image_entity.dart';

class ImageCard extends StatelessWidget {
  final ImageEntity img;
  final AnimationController favoriteController;
  final VoidCallback onTap;
  final Key? repaintKey;

  const ImageCard({
    required this.img,
    required this.favoriteController,
    required this.onTap,
    this.repaintKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Hero(
                tag: 'image_${img.id}',
                child: CachedNetworkImage(
                  imageUrl: img.downloadUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 200, color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, size: 50, color: Colors.red),
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  img.author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('ID: ${img.id}'),
                trailing: AnimatedBuilder(
                  animation: favoriteController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + favoriteController.value * 0.2,
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          favoriteController.forward().then((_) {
                            favoriteController.reverse();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${img.author} to favorites'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 