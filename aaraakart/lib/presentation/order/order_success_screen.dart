import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/data/model/order_success_route_model.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_icon_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/lottie_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderSuccessRouteModel orderDetails;
  final bool isSubscription;

  const OrderSuccessScreen(
      {super.key, required this.orderDetails, required this.isSubscription});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: MyAppText(data: 'Go to Home'),
        onLeadingTap: () {
          context.go('/bottom-bar');
        },
      ),
      backgroundColor: AppColors.backgroundBase,
      body: _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          _buildSuccessAnimation(),
          _buildSuccessMessage(),
          SizedBox(height: 30.h),
          _buildOrderDetails(),
          SizedBox(height: 30.h),
          _buildDeliveryInfo(),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return SizedBox(
        height: 200.h,
        child: MyLottieAnimation(
          assetPath: AppAssets.successJson,
          repeat: false,
          fit: BoxFit.cover,
        ));
  }

  Widget _buildSuccessMessage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          MyAppText(
            data: widget.isSubscription
                ? '🎉 Subscription Confirmed!'
                : '🎉 Order Confirmed!',
            size: 20.sp,
            weight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.badgeSuccess.withOpacity(0.1),
                  AppColors.brandPrimary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: AppColors.badgeSuccess.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: MyAppText(
              data: 'Your fresh farm products are being prepared with care',
              size: 12.sp,
              maxLines: 2,
              color: AppColors.textSecondary,
              lineHeight: 1.4,
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MyAppIconButton(
                  icon: Icons.access_time_rounded,
                  onPressed: () {},
                  variant: "color",
                ),
                SizedBox(width: 12.w),
                MyAppText(
                  data: 'Order Details',
                  size: 13.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            // SizedBox(height: 16.h),
            // _buildInfoRow(
            //   'Total Amount',
            //   '₹${widget.orderDetails.totalAmount}',
            // ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Order ID',
              widget.orderDetails.orderId.toString(),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Total Amount',
              '₹${widget.orderDetails.totalAmount}',
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Payment Method',
              widget.orderDetails.paymentMethod.toString(),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Order Date',
              widget.orderDetails.orderDate.toString(),
            ),
            if (widget.isSubscription &&
                widget.orderDetails.subscriptionId != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Subscription ID',
                widget.orderDetails.subscriptionId.toString(),
              ),
            ],
            if (widget.isSubscription &&
                widget.orderDetails.deliverySchedule != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Delivery Schedule',
                widget.orderDetails.deliverySchedule.toString(),
              ),
            ],
            if (widget.isSubscription &&
                widget.orderDetails.deliverySlot != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Delivery Slot',
                widget.orderDetails.deliverySlot.toString(),
              ),
            ],
            if (widget.isSubscription &&
                (widget.orderDetails.deliveryDays?.isNotEmpty ?? false)) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                'Delivery Days',
                widget.orderDetails.deliveryDays!.join(', '),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MyAppIconButton(
                  icon: Iconsax.truck_fast_bold,
                  onPressed: () {},
                  variant: "color",
                ),
                SizedBox(width: 12.w),
                MyAppText(
                  data: 'Delivery Information',
                  size: 13.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brandPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.calendar_2_bold,
                    color: AppColors.brandPrimary,
                    size: 18.r,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: MyAppText(
                      data: widget.orderDetails.deliveryInfo.toString(),
                      size: 10.sp,
                      weight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyAppButton(
              onPressed: () => context.go('/bottom-bar'),
              label: 'Continue Shopping',
              icon: Iconsax.shopping_bag_outline,
            ),
          ],
        ),
      ),
    );
  }
}


