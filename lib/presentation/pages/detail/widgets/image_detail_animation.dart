import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ImageDetailAnimation extends StatelessWidget {
  const ImageDetailAnimation({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/lottie_lego.json',
        width: 200,
        height: 200,
        repeat: true,
        animate: true,
      ),
    );
  }
}
