import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_state.dart';
import 'package:aaraa_kart/data/model/get_customer_subs.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/build_msg_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class SubscriptionsHistoryScreen extends StatefulWidget {
  const SubscriptionsHistoryScreen({super.key});

  @override
  State<SubscriptionsHistoryScreen> createState() =>
      _SubscriptionsHistoryScreenState();
}

class _SubscriptionsHistoryScreenState
    extends State<SubscriptionsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        showLeading: true,
        title: MyAppText(
          data: 'Past Subscriptions',
          weight: FontWeight.w700,
          size: 18.sp,
        ),
      ),
      body: BlocConsumer<SubscriptionsCubit, SubscriptionState>(
        buildWhen: (previous, current) => previous != current,
        listener: (context, state) {},
        builder: (context, state) {
          List<GetCustomerSubscriptionsResponseModel>? subscriptionsData =
              state is SubscriptionSuccess ? state.subscriptions : [];
          return _buildPastSubscriptionsTab(subscriptionsData);
        },
      ),
    );
  }

  Widget _buildPastSubscriptionsTab(
      List<GetCustomerSubscriptionsResponseModel>? subscriptionsData) {
    final pastSubscriptions = subscriptionsData!
        .where((p) =>
            p.status != "active" &&
            p.status != "on-hold" &&
            p.status != "pending")
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: pastSubscriptions.isEmpty
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: buildMsgState(context, 'No Data Available', '',
                    () => context.pop(), 'Go Back', Icons.card_membership),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pastSubscriptions.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildSubscriptionCard(pastSubscriptions[index]);
              },
            ),
    );
  }

  Widget _buildSubscriptionCard(GetCustomerSubscriptionsResponseModel product) {
    final status = product.status ?? '';
    final isCancelled = status == 'cancelled';

    final statusColor = isCancelled ? AppColors.error : AppColors.textTertiary;
    final statusIcon =
        isCancelled ? Iconsax.close_circle_bold : Iconsax.timer_bold;
    final statusLabel = isCancelled ? 'Cancelled' : 'Expired';

    final endDate = _tryParseDate(product.cancelledDateGmt) ??
        _tryParseDate(product.endDateGmt) ??
        _tryParseDate(product.dateModified);

    final lineItem =
        product.lineItems?.isNotEmpty == true ? product.lineItems!.first : null;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBase,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: lineItem?.image?.src != null
                        ? MyAppCachedImage(
                            imageUrl: lineItem!.image!.src.toString(),
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Iconsax.box_outline,
                            size: 18.sp,
                            color: AppColors.textTertiary,
                          ),
                  ),
                  Positioned(
                    right: -4.w,
                    bottom: -4.w,
                    child: Container(
                      padding: EdgeInsets.all(3.5.r),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(statusIcon, size: 9.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppText(
                      data: lineItem?.name?.toString() ?? 'Subscription',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      weight: FontWeight.w600,
                      size: 12.sp,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 3.h),
                    MyAppText(
                      data: 'Qty ${lineItem?.quantity ?? 1} · #${product.id}',
                      size: 9.5.sp,
                      weight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              MyAppText(
                data: '₹${lineItem?.price?.toString() ?? product.total}',
                weight: FontWeight.bold,
                size: 13.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: statusColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, size: 12.sp, color: statusColor),
                SizedBox(width: 6.w),
                MyAppText(
                  data: endDate != null
                      ? '$statusLabel on ${DateFormat('MMM d, yyyy').format(endDate)}'
                      : statusLabel,
                  size: 10.sp,
                  weight: FontWeight.w600,
                  color: statusColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _tryParseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}


