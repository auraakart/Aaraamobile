import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  VoidCallback? onTap,
  bool isIconOnly = false,
  bool isLoading = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: isIconOnly ? 12.w : 16.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: onTap == null ? color.withOpacity(0.05) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 18.r,
              height: 18.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ] else ...[
            Icon(icon,
                color: onTap == null ? color.withOpacity(0.5) : color,
                size: 14.r),
          ],
          if (!isIconOnly && !isLoading) ...[
            SizedBox(width: 6.w),
            MyAppText(
              data: label,
              color: onTap == null ? color.withOpacity(0.5) : color,
              size: 10.sp,
              weight: FontWeight.w600,
            ),
          ],
        ],
      ),
    ),
  );
}


