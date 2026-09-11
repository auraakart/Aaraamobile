import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/whatsapp_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class OrderFailedScreen extends StatefulWidget {
  final String? errorMessage;
  final String? errorCode;
  final String? transactionId;

  const OrderFailedScreen({
    super.key,
    this.errorMessage,
    this.errorCode,
    this.transactionId,
  });

  @override
  State<OrderFailedScreen> createState() => _OrderFailedScreenState();
}

class _OrderFailedScreenState extends State<OrderFailedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        title: MyAppText(data: 'Go to Home'),
        onLeadingTap: () => context.go('/bottom-bar'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 96.r,
                  height: 96.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 48.r,
                    color: AppColors.error,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              FadeTransition(
                opacity: _fadeAnimation,
                child: MyAppText(
                  data: 'Payment Failed',
                  size: 20.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  align: TextAlign.center,
                ),
              ),
              SizedBox(height: 8.h),
              FadeTransition(
                opacity: _fadeAnimation,
                child: MyAppText(
                  data: widget.errorMessage ??
                      'Something went wrong while processing your payment. If any amount was deducted, it will be refunded shortly.',
                  size: 12.sp,
                  color: AppColors.textSecondary,
                  align: TextAlign.center,
                  maxLines: 3,
                  lineHeight: 1.5,
                ),
              ),
              if (widget.transactionId != null) ...[
                SizedBox(height: 16.h),
                MyAppText(
                  data: 'Order ID: ${widget.transactionId}',
                  size: 11.sp,
                  color: AppColors.textTertiary,
                  align: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
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
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyAppButton(
              onPressed: () => context.go('/bottom-bar'),
              label: 'Go to Home',
              icon: Iconsax.home_outline,
            ),
            SizedBox(height: 8.h),
            TextButton.icon(
              onPressed: () => handleWhatsAppLauncher(
                BrandConfig.instance.content.whatsappNumber,
                widget.transactionId != null
                    ? 'Hi, I need help with my order. My order ID is ${widget.transactionId} - the payment failed.'
                    : 'Hi, I need help - my payment failed.',
                context,
              ),
              icon: Icon(Icons.support_agent_rounded,
                  size: 18.r, color: AppColors.textSecondary),
              label: MyAppText(
                data: 'Contact Support',
                size: 12.sp,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


