import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color foregroundColor;
  final double? fontSize;
  final double? imageSize;
  final FontWeight fontWeight;
  final double? elevation;
  final bool? loading;
  final bool? isDisabled;

  const MyAppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.fontSize,
    this.imageSize,
    this.fontWeight = FontWeight.bold,
    this.elevation = 0,
    this.loading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled == true
            ? null
            : loading!
                ? () {}
                : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.brandPrimary,
          foregroundColor: foregroundColor,
          padding: padding ?? EdgeInsets.symmetric(vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
          ),
          elevation: elevation,
        ),
        child: loading!
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      size: imageSize ?? 20.r,
                      color: AppColors.backgroundSurface,
                    ),
                  if (icon != null) SizedBox(width: 8.w),
                  MyAppText(
                    data: label,
                    style: TextStyle(
                      fontSize: fontSize ?? 12.sp,
                      fontWeight: fontWeight,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


