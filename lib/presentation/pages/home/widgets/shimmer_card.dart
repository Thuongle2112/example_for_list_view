import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
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
} 