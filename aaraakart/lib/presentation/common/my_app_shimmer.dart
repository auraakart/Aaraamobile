import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MyAppShimmer extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const MyAppShimmer({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
          baseColor: setColorBasedOnTheme(
              context: context,
              lightColor: AppColors.shimmerBaseLight,
              darkColor: AppColors.shimmerBaseDark),
          highlightColor: setColorBasedOnTheme(
              context: context,
              lightColor: AppColors.shimmerDragLight,
              darkColor: AppColors.shimmerDragDark)),
      enabled: isLoading,
      child: child,
    );
  }
}


