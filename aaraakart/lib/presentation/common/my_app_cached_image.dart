import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAppCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final Widget? placeholderWidget;
  final Widget? errorWidget;

  const MyAppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.fill,
    this.height,
    this.width,
    this.placeholderWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl.isEmpty ? '' : imageUrl,
      fit: fit,
      height: height,
      width: width,
      placeholder: (context, url) =>
          placeholderWidget ??
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
            ),
          ),
      errorWidget: (context, url, error) {
        debugPrint('❌ IMAGE LOAD FAILED');
        debugPrint('URL: $url');
        debugPrint('ERROR: $error');

        return errorWidget ??
            Container(
              color: AppColors.brandPrimary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textSecondary.withOpacity(0.3),
                  size: 20.r,
                ),
              ),
            );
      },
    );
  }
}
