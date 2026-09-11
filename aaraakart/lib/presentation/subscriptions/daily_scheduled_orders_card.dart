import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/data/model/scheduled_delivery_item.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class DailyScheduledOrdersCard extends StatelessWidget {
  final DateTime selectedDate;
  final List<ScheduledDeliveryItem> deliveries;
  final VoidCallback onScheduleFutureDelivery;

  const DailyScheduledOrdersCard({
    super.key,
    required this.selectedDate,
    required this.deliveries,
    required this.onScheduleFutureDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(selectedDate);
    final rawMonth = DateFormat('MMM').format(selectedDate).toUpperCase();
    final month = rawMonth == 'SEP' ? 'SEPT' : rawMonth;
    final year = DateFormat('yy').format(selectedDate);
    final weekday = DateFormat('EEEE').format(selectedDate).toUpperCase();
    final headerDate = '$day-$month-$year ($weekday) - DELIVERY';
    final buttonDate = DateFormat('MMM d').format(selectedDate);

    final subDeliveries = deliveries.where((d) => !d.isOneTime).toList();
    final futureDeliveries = deliveries.where((d) => d.isOneTime).toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPastDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
            .isBefore(today);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.calendarCardBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date
          MyAppText(
            data: headerDate,
            size: 12.sp,
            weight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 12.h),

          // 1. Subscription Deliveries Section
          if (subDeliveries.isNotEmpty) ...[
            MyAppText(
              data: 'Subscription Deliveries',
              size: 13.sp,
              weight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 8.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subDeliveries.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                return _buildItemRow(subDeliveries[index]);
              },
            ),
          ],

          // 2. Future / Extra Orders Section
          if (futureDeliveries.isNotEmpty) ...[
            if (subDeliveries.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Divider(
                height: 1,
                color: AppColors.borderDefault.withValues(alpha: 0.5),
              ),
              SizedBox(height: 10.h),
            ],
            MyAppText(
              data: isPastDate ? 'Delivered Orders' : 'Future / Extra Orders',
              size: 13.sp,
              weight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 8.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: futureDeliveries.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                return _buildItemRow(futureDeliveries[index]);
              },
            ),
          ],

          // If neither exists
          if (subDeliveries.isEmpty && futureDeliveries.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: MyAppText(
                  data: 'No deliveries scheduled for this day',
                  size: 12.sp,
                  weight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          // 3. Add Order Button (Only for Today and Future dates)
          if (!isPastDate) ...[
            SizedBox(height: 16.h),
            InkWell(
              onTap: onScheduleFutureDelivery,
              borderRadius: BorderRadius.circular(28.r),
              child: Container(
                width: double.infinity,
                height: 44.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: MyAppText(
                  data: '[+ Add Order for $buttonDate]',
                  size: 13.sp,
                  weight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(ScheduledDeliveryItem item) {
    final slot = item.deliverySlot != null && item.deliverySlot!.isNotEmpty
        ? item.deliverySlot!
        : '6-8 AM';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.calendarItemIconBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.borderDefault.withValues(alpha: 0.6),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.productImage != null && item.productImage!.isNotEmpty
              ? MyAppCachedImage(
                  imageUrl: item.productImage!,
                  fit: BoxFit.contain,
                )
              : Icon(
                  item.productName.toLowerCase().contains('milk')
                      ? Icons.local_drink_outlined
                      : Iconsax.box_outline,
                  size: 22.sp,
                  color: AppColors.textPrimary,
                ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyAppText(
                data: item.productName,
                size: 13.sp,
                weight: FontWeight.w700,
                color: AppColors.textPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              MyAppText(
                data: 'Qty ${item.quantity} · Slot: $slot',
                size: 11.5.sp,
                weight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        if (item.price > 0)
          MyAppText(
            data: '₹${item.price.toStringAsFixed(0)}',
            size: 14.5.sp,
            weight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
      ],
    );
  }
}
