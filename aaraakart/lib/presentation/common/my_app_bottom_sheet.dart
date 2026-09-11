import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBottomSheet extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onNext;
  final String title;
  final String subTitle;

  const AppBottomSheet({
    super.key,
    required this.onCancel,
    required this.onNext,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          MyAppText(
            data: title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.brandPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: MyAppButton(
                onPressed: onCancel,
                label: "No",
                backgroundColor: AppColors.shimmerBaseDark,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: MyAppButton(onPressed: onNext, label: "Yes"),
            )
          ])
        ],
      ),
    );
  }
}


