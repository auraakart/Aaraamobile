import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyLottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;
  final bool animate;
  final BoxFit fit;

  const MyLottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.repeat = true,
    this.animate = true,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      animate: animate,
      fit: fit,
    );
  }
}


