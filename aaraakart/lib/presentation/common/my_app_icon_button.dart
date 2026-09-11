import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAppIconButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final double? iconSize;
  final double? minWidth;
  final double? minHeight;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final String variant;

  const MyAppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 22,
    this.minWidth,
    this.minHeight,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.iconColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(99)),
    this.variant = 'default',
  });

  @override
  Widget build(BuildContext context) {
    return variant == "default"
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                icon,
                color: iconColor ?? AppColors.brandPrimary,
                size: iconSize,
              ),
              onPressed: onPressed,
            ),
          )
        : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.brandPrimary,
              size: iconSize ?? 16.r,
            ),
          );
  }
}


