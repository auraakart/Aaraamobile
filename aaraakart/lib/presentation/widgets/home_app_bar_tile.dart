import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeAppBarTitle extends StatelessWidget {
  const HomeAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.asset(
            AppAssets.logoTFV,
            fit: BoxFit.contain,
            height: 28.h,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/location-selection'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyAppText(
                  data: 'Delivery to',
                  size: 10.sp,
                  color: AppColors.textSecondary,
                ),
                Row(
                  children: [
                    BlocBuilder<StorageCubit, StorageState>(
                      builder: (context, state) {
                        String? addressType;

                        try {
                          if (state.addressData.isEmpty) {
                            addressType = null;
                          } else {
                            final defaultItem = state.addressData.firstWhere(
                              (item) => item.isPrimary == 1,
                            );

                            addressType = defaultItem?.label;
                          }
                        } catch (e) {
                          addressType = null;
                        }
                        return Flexible(
                          child: MyAppText(
                            data: state.addressData.isEmpty
                                ? 'Your Location'
                                : addressType == 'Home'
                                    ? "Home"
                                    : addressType == 'Work'
                                        ? "Work"
                                        : "Other",
                            size: 13.sp,
                            weight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 14.r,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


