import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildMsgState(BuildContext context, title, subtitle,
    VoidCallback? onPress, buttonName, IconData? icon,
    {showButton = true}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon ?? Icons.lock,
          size: 70.r,
          color: Colors.grey.shade300,
        ),
        SizedBox(height: 12.h),
        MyAppText(
          data: title,
          size: 13.sp,
          color: AppColors.textSecondary,
          weight: FontWeight.w500,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: MyAppText(
            data: subtitle,
            align: TextAlign.center,
            size: 11.sp,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        if (showButton)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onPress,
            child: MyAppText(
              data: buttonName,
              color: Colors.white,
              size: 12.sp,
            ),
          ),
      ],
    ),
  );
}


