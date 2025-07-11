import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../bloc/image_bloc.dart';
import '../../domain/entities/image_entity.dart';
import 'detail/image_detail_page.dart';
import 'qr/qr_generate_page.dart';

class ImageListViewPage extends StatefulWidget {
  const ImageListViewPage({super.key});

  @override
  State<ImageListViewPage> createState() => _ImageListViewPageState();
}

class _ImageListViewPageState extends State<ImageListViewPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  late AnimationController _favoriteController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ImageBloc>().add(LoadMoreImages());
    }
  }

  void _onRefresh() async {
    context.read<ImageBloc>().add(FetchImagesEvent());
    _refreshController.refreshCompleted();
  }

  void _handleQrResult(dynamic qrResult) {
    if (qrResult is Map<String, dynamic>) {
      // Handle JSON data from QR
      final albumId = qrResult['albumId'];
      final title = qrResult['title'];
      final images = qrResult['images'] as List<dynamic>?;
      
      if (images != null && images.isNotEmpty) {
        // Convert to ImageEntity list
        final imageEntities = images.map((img) {
          if (img is String) {
            return ImageEntity(
              id: img.hashCode.toString(),
              author: 'QR Album',
              downloadUrl: img,
            );
          }
          return null;
        }).whereType<ImageEntity>().toList();
        
        if (imageEntities.isNotEmpty) {
          // Load images from QR - for now just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã mở album: $title (${imageEntities.length} ảnh)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else if (qrResult is String) {
      // Handle plain text from QR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR content: $qrResult'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(height: 200, color: Colors.white),
            ListTile(
              title: Container(height: 16, color: Colors.white),
              subtitle: Container(height: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView Demo'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Tạo QR cho album',
            onPressed: () async {
              // Lấy danh sách ảnh hiện tại từ Bloc
              final state = context.read<ImageBloc>().state;
              if (state is ImageLoaded && state.images.isNotEmpty) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrGeneratePage(
                      images: state.images,
                      albumName: 'My Photo Album',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No images to create QR for')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Quét QR mở album',
            onPressed: () async {
              final qrResult = await Navigator.pushNamed(context, '/qr-scan');
              if (qrResult != null) {
                _handleQrResult(qrResult);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageLoading) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => _buildShimmerCard(),
            );
          } else if (state is ImageLoaded) {
            if (state.images.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text('No images found'),
                    SizedBox(height: 8),
                    Text('Pull down to refresh'),
                  ],
                ),
              );
            }

            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              header: const WaterDropHeader(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.hasMore
                    ? state.images.length + 1
                    : state.images.length,
                itemBuilder: (context, index) {
                  if (index >= state.images.length) {
                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      // child: Center(child: CircularProgressIndicator()),
                      child: Center(
                        child: Lottie.asset(
                          'assets/animations/lottie_lego.json',
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.width * 0.2,
                          repeat: true,
                          animate: true,
                        ),
                      ),
                    );
                  }

                  final img = state.images[index];

                  return RepaintBoundary(
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ImageDetailPage(image: img),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Hero(
                              tag: 'image_${img.id}',
                              child: CachedNetworkImage(
                                imageUrl: img.downloadUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 200,
                                        color: Colors.white,
                                      ),
                                    ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                img.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('ID: ${img.id} - Index: $index'),
                              trailing: AnimatedBuilder(
                                animation: _favoriteController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        1.0 + _favoriteController.value * 0.2,
                                    child: IconButton(
                                      icon: const Icon(Icons.favorite_border),
                                      onPressed: () {
                                        _favoriteController.forward().then((_) {
                                          _favoriteController.reverse();
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Added ${img.author} to favorites',
                                            ),
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
                },
              ),
            );
          } else if (state is ImageError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ImageBloc>().add(FetchImagesEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
