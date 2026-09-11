import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

enum OrderTypeFilter {
  both,
  subscription,
  oneTime,
}

class OrderHistoryFilterSheet extends StatefulWidget {
  final OrderTypeFilter initialFilter;
  final ValueChanged<OrderTypeFilter> onApply;

  const OrderHistoryFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required OrderTypeFilter currentFilter,
    required ValueChanged<OrderTypeFilter> onFilterSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => OrderHistoryFilterSheet(
        initialFilter: currentFilter,
        onApply: onFilterSelected,
      ),
    );
  }

  @override
  State<OrderHistoryFilterSheet> createState() =>
      _OrderHistoryFilterSheetState();
}

class _OrderHistoryFilterSheetState extends State<OrderHistoryFilterSheet> {
  late OrderTypeFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderDisabled,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Filter Orders',
                  size: 16.sp,
                  weight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                if (_tempFilter != OrderTypeFilter.both)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _tempFilter = OrderTypeFilter.both;
                      });
                    },
                    child: MyAppText(
                      data: 'Reset',
                      size: 12.sp,
                      weight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            MyAppText(
              data: 'Select the type of orders you want to view',
              size: 11.sp,
              weight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 18.h),
            _buildFilterOptionTile(
              title: 'Both',
              subtitle: 'Show all subscription and one-time orders',
              icon: Iconsax.element_4_outline,
              isSelected: _tempFilter == OrderTypeFilter.both,
              onTap: () {
                setState(() {
                  _tempFilter = OrderTypeFilter.both;
                });
              },
            ),
            SizedBox(height: 10.h),
            _buildFilterOptionTile(
              title: 'Subscription Order',
              subtitle: 'Show only recurring subscription orders',
              icon: Iconsax.calendar_1_outline,
              isSelected: _tempFilter == OrderTypeFilter.subscription,
              onTap: () {
                setState(() {
                  _tempFilter = OrderTypeFilter.subscription;
                });
              },
            ),
            SizedBox(height: 10.h),
            _buildFilterOptionTile(
              title: 'One-Time Order',
              subtitle: 'Show only one-time / scheduled orders',
              icon: Iconsax.shopping_bag_outline,
              isSelected: _tempFilter == OrderTypeFilter.oneTime,
              onTap: () {
                setState(() {
                  _tempFilter = OrderTypeFilter.oneTime;
                });
              },
            ),
            SizedBox(height: 22.h),
            MyAppButton(
              label: 'Apply Filter',
              backgroundColor: AppColors.textPrimary,
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(_tempFilter);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.textPrimary.withValues(alpha: 0.04)
              : AppColors.backgroundBase,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.borderDefault,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 17.sp,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppText(
                    data: title,
                    size: 13.sp,
                    weight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 2.h),
                  MyAppText(
                    data: subtitle,
                    size: 10.5.sp,
                    weight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 20.r,
              height: 20.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.borderDisabled,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 13.sp,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
