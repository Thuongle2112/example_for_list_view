import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:example_for_list_view/domain/entities/image_entity.dart';

class QrGeneratePage extends StatefulWidget {
  final List<ImageEntity> images;
  final String albumName;

  const QrGeneratePage({
    super.key,
    required this.images,
    required this.albumName,
  });

  @override
  State<QrGeneratePage> createState() => _QrGeneratePageState();
}

class _QrGeneratePageState extends State<QrGeneratePage> {
  late String qrData;
  final TextEditingController _albumNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _albumNameController.text = widget.albumName;
    _generateQrData();
  }

  void _generateQrData() {
    // Tạo dữ liệu QR với thông tin album
    final albumInfo = {
      'type': 'album',
      'name': _albumNameController.text,
      'imageCount': widget.images.length,
      'albumId': 'album_${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toIso8601String(),
      'images': widget.images.map((img) => {
        'id': img.id,
        'author': img.author,
        'url': img.downloadUrl,
      }).toList(),
    };
    
    qrData = albumInfo.toString();
  }

  void _shareQr() {
    Share.share(
      'Check out this album: ${_albumNameController.text}\n\nQR Code contains ${widget.images.length} images\n\nScan the QR code to open this album!',
      subject: 'Album QR Code: ${_albumNameController.text}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Album QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQr,
            tooltip: 'Share QR',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Album Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Album Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _albumNameController,
                      decoration: const InputDecoration(
                        labelText: 'Album Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _generateQrData();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Images: ${widget.images.length}'),
                    Text('Generated: ${DateTime.now().toString().substring(0, 19)}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // QR Code
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'QR Code',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan this QR code to open the album',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Album Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Album Preview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.images.length > 5 ? 5 : widget.images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(widget.images[index].downloadUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (widget.images.length > 5)
                      Text(
                        '... and ${widget.images.length - 5} more images',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _albumNameController.dispose();
    super.dispose();
  }
} 