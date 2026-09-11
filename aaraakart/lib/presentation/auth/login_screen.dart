import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class LoginScreen extends StatefulWidget {
  final bool? isGuestMode;
  const LoginScreen({super.key, this.isGuestMode});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, [Color? backgroundColor]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: backgroundColor ?? AppColors.brandPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: widget.isGuestMode == true
          ? MyAppBar(
              backgroundColor: Colors.transparent,
              title: const Text(""),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!(widget.isGuestMode ?? false)) ...[
                        SizedBox(height: 20.h),
                        _buildHeader(),
                      ],
                      SizedBox(height: 20.h),
                      _buildPhoneForm(),
                      if (!(widget.isGuestMode ?? false)) ...[
                        SizedBox(height: 8.h),
                        _buildAlternativeOptions(),
                      ],
                      const Spacer(),
                      _buildTermsFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Hero(
              tag: 'app_logo',
              child: Image.asset(
                AppAssets.logoTFV,
                width: 100.w,
                height: 80.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.eco_rounded,
                    color: AppColors.brandPrimary,
                    size: 32.r,
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        MyAppText(
          data: BrandConfig.instance.content.welcomeTitle,
          size: 14.sp,
          weight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimaryDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.mobile_outline,
                  color: AppColors.brandPrimary,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              MyAppText(
                data: "Mobile Number",
                color: AppColors.textPrimary,
                size: 14.sp,
                weight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 47.w),
            child: MyAppText(
              data: "We'll send you an OTP for verification",
              color: AppColors.textSecondary,
              size: 11.sp,
            ),
          ),
          SizedBox(height: 20.h),
          MyAppTextField(
            controller: _phoneController,
            hintText: "Enter your mobile number",
            prefixText: "+91 ",
            isNumber: true,
            maxLength: 10,
          ),
          SizedBox(height: 20.h),
          _buildGetOtpButton(),
        ],
      ),
    );
  }

  Widget _buildGetOtpButton() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SendOTPSuccess) {
          if (state.data.success == true) {
            context.push(
              '/otp',
              extra: {'phoneNumber': _phoneController.text.trim()},
            );
          } else {
            _showSnackBar(state.data.message ?? 'Failed to send OTP',
                Colors.red.shade600);
          }
        } else if (state is SendOTPError) {
          _showSnackBar(state.message, Colors.red.shade600);
        }
      },
      builder: (context, state) {
        final isLoading = state is SendOTPLoading ? state.isLoading : false;

        return MyAppButton(
          loading: isLoading,
          label: "GET OTP",
          onPressed: () {
            final phone = _phoneController.text.trim();
            if (phone.isEmpty ||
                phone.length != 10 ||
                int.tryParse(phone) == null) {
              _showSnackBar('Please enter a valid 10-digit mobile number',
                  Colors.red.shade600);
              return;
            }
            context.read<AuthCubit>().sendOtp(phone);
          },
          icon: Icons.arrow_forward_rounded,
        );
      },
    );
  }

  Widget _buildAlternativeOptions() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            children: [
              Expanded(child: Divider(color: AppColors.borderDefault)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: MyAppText(
                  data: "OR",
                  color: AppColors.textSecondary,
                  size: 14.sp,
                  weight: FontWeight.w500,
                ),
              ),
              Expanded(child: Divider(color: AppColors.borderDefault)),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildAlternativeCard(
                icon: Iconsax.shopping_bag_bold,
                label: "Browse as Guest",
                color: AppColors.brandSecondary,
                onTap: () {
                  context.read<StorageCubit>().removeAddress();
                  context.read<StorageCubit>().setIsGuestMode(true);
                  context.go("/bottom-bar");
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildAlternativeCard(
                icon: Iconsax.shop_bold,
                label: "Become a Vendor",
                color: AppColors.brandPrimary,
                onTap: () {
                  _showSnackBar('Vendor registration coming soon!');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlternativeCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.w),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 12.h),
            MyAppText(
              data: label,
              align: TextAlign.center,
              size: 12.sp,
              weight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          MyAppText(
            data: "By continuing you agree to our",
            size: 10.sp,
            align: TextAlign.center,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showSnackBar('Opening Terms of Service'),
                child: MyAppText(
                  data: "Terms of Service",
                  color: AppColors.brandPrimary,
                  weight: FontWeight.w600,
                  size: 10.sp,
                ),
              ),
              MyAppText(
                data: " and ",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
              GestureDetector(
                onTap: () => _showSnackBar('Opening Privacy Policy'),
                child: MyAppText(
                  data: "Privacy Policy",
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


