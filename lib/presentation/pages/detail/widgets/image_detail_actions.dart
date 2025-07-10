import 'package:flutter/material.dart';

class ImageDetailActions extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final bool isSharing;
  const ImageDetailActions({super.key, required this.onDownload, required this.onShare, required this.isSharing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSharing ? null : onShare,
            icon: isSharing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.share),
            label: Text(isSharing ? 'Sharing...' : 'Share'),
          ),
        ),
      ],
    );
  }
}
