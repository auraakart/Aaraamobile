import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionCutoffHelper {
  static const String cutoffMessage =
      'Pausing deliveries is temporarily unavailable from 11:55 PM to 12:00 AM for daily schedule maintenance. Deliveries can be resumed at any time.';

  /// Returns true if the given or current time falls within the 11:55 PM – 11:59:59 PM cutoff window.
  /// At 12:00 AM (00:00) onward, it returns false.
  static bool isPauseRestricted([DateTime? currentTime]) {
    final now = currentTime ?? DateTime.now();
    return now.hour == 23 && now.minute >= 55;
  }

  /// Checks if subscription pausing is currently restricted.
  /// If restricted, displays the required SnackBar and returns true.
  /// Otherwise, returns false.
  static bool checkAndShowCutoffSnackBar(BuildContext context) {
    if (isPauseRestricted()) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: MyAppText(
            data: cutoffMessage,
            color: AppColors.white,
            size: 12.sp,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          margin: EdgeInsets.all(12.r),
          duration: const Duration(seconds: 4),
        ),
      );
      return true;
    }
    return false;
  }
}
