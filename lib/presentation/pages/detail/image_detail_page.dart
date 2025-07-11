import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher  .dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:example_for_list_view/domain/entities/image_entity.dart';
import 'package:example_for_list_view/presentation/pages/detail/widgets/image_detail_header.dart';
import 'package:example_for_list_view/presentation/pages/detail/widgets/image_detail_info.dart';
import 'package:example_for_list_view/presentation/pages/detail/widgets/image_detail_actions.dart';
import 'package:example_for_list_view/presentation/pages/detail/widgets/image_detail_share_option.dart';
import 'package:example_for_list_view/presentation/pages/detail/widgets/image_detail_animation.dart';
import 'package:example_for_list_view/presentation/pages/detail/widgets/battery_button.dart';

class ImageDetailPage extends StatefulWidget {
  final ImageEntity image;

  const ImageDetailPage({super.key, required this.image});

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  bool _isSharing = false;

  Future<void> _shareImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      await Share.share(
        'Check out this amazing photo by ${widget.image.author}!\n\nImage ID: ${widget.image.id}\n\n${widget.image.downloadUrl}',
        subject: 'Amazing Photo by ${widget.image.author}',
      );
    } catch (e) {
      print('Error sharing image: $e');
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _shareBasicInfo() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      await Share.share(
        'Photo by ${widget.image.author}\nID: ${widget.image.id}',
        subject: 'Photo Information',
      );
    } catch (e) {
      print('Error sharing basic info: $e');
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  // Future<void> _downloadImage() async {
  //   try {
  //     final url = Uri.parse(widget.image.downloadUrl);
  //     if (await canLaunchUrl(url)) {
  //       await launchUrl(url, mode: LaunchMode.externalApplication);
  //     }
  //   } catch (e) {
  //     print('Error downloading image: $e');
  //   }
  // }

Future<void> _downloadImage() async {
  final url = widget.image.downloadUrl;

  try {
    // Lấy thư mục tạm
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${widget.image.id}.jpg';

    // Tải ảnh từ URL về máy
    await Dio().download(url, filePath);

    // Lưu ảnh từ máy vào gallery
    final result = await GallerySaver.saveImage(filePath);
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Image saved to gallery')),
      );
    } else {
      throw 'Image save failed';
    }
  } catch (e) {
    print('❌ Error saving image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Failed to save image')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.image.author),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isSharing ? null : _shareImage,
            tooltip: 'Share Image',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageDetailHeader(image: widget.image),
              const SizedBox(height: 20),
              ImageDetailInfo(image: widget.image),
              const SizedBox(height: 20),
              ImageDetailActions(
                onDownload: _downloadImage,
                onShare: _shareImage,
                isSharing: _isSharing,
              ),
              const SizedBox(height: 20),
              ImageDetailShareOptions(
                downloadUrl: widget.image.downloadUrl,
                author: widget.image.author,
                id: widget.image.id,
                isSharing: _isSharing,
                onShareInfo: _shareBasicInfo,
              ),
              const SizedBox(height: 20),
              ImageDetailAnimation(),
              const SizedBox(height: 20),
              BatteryButton(),
              // Thông tin ảnh
            ],
          ),
        ),
      ),
    );
  }
}
