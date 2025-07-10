import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageDetailShareOptions extends StatelessWidget {
  final String downloadUrl;
  final String author;
  final String id;
  final bool isSharing;
  final VoidCallback onShareInfo;
  const ImageDetailShareOptions({
    super.key,
    required this.downloadUrl,
    required this.author,
    required this.id,
    required this.isSharing,
    required this.onShareInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy Link'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: downloadUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image link copied to clipboard!')),
                  );
                },
              ),
            ),
            Expanded(
              child: ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Share Info'),
                onTap: isSharing ? null : onShareInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
