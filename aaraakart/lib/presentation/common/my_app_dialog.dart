import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAppDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String positiveText;
  final String negativeText;
  final VoidCallback onPositivePressed;
  final VoidCallback onNegativePressed;

  const MyAppDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.positiveText,
    required this.negativeText,
    required this.onPositivePressed,
    required this.onNegativePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyAppText(
              data: title,
              align: TextAlign.center,
              color: AppColors.textPrimary,
              size: 14.sp,
              weight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            MyAppText(
              data: subtitle,
              align: TextAlign.center,
              color: AppColors.textSecondary,
              size: 12.sp,
              maxLines: 6,
              overflow: TextOverflow.visible,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNegativePressed,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      negativeText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPositivePressed,
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      positiveText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


