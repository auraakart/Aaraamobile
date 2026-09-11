import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class MyAppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final bool isSearch;
  final bool isNumber;
  final int? maxLength;
  final bool obscureText;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  final bool enabled;
  final Color? fillColor;
  const MyAppTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.hintStyle,
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.isSearch = false,
    this.isNumber = false,
    this.maxLength,
    this.fillColor,
    this.obscureText = false,
    this.borderRadius = 16,
    this.contentPadding,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: textStyle ??
          TextStyle(
            fontSize: 12.sp,
            color: AppColors.textPrimary,
          ),
      obscureText: obscureText,
      inputFormatters: [
        if (isNumber) ...[
          FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ]
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        fillColor: fillColor ?? AppColors.backgroundBase,
        hintText: hintText,
        hintStyle: hintStyle ??
            TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 12.sp,
            ),
        prefixIcon: isSearch
            ? Padding(
                padding: EdgeInsets.all(12.r),
                child: Icon(
                  Iconsax.search_normal_outline,
                  color: AppColors.brandPrimary,
                  size: 18.r,
                ),
              )
            : prefixIcon ??
                (prefixText != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                        child: MyAppText(
                          data: prefixText!,
                          size: 12.sp,
                          color: AppColors.textPrimary,
                          weight: FontWeight.w500,
                        ),
                      )
                    : null),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.brandPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.brandPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.brandPrimary,
            width: 1,
          ),
        ),
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      ),
    );
  }
}


