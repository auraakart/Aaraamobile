import 'dart:async';

import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/utils/post_login_loader.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_snackbar.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _remainingSeconds = 30;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _pinController.text.trim();
    if (!_isValidOtp(otp)) return;

    context.read<AuthCubit>().verifyOTP(widget.phoneNumber, otp);
  }

  bool _isValidOtp(String otp) {
    if (otp.isEmpty) {
      myAppSnackError('Please enter the OTP', context);
      return false;
    }

    if (otp.length != 6) {
      myAppSnackError('Please enter a valid 6-digit OTP', context);
      return false;
    }

    if (int.tryParse(otp) == null) {
      myAppSnackError('OTP should contain only numbers', context);
      return false;
    }

    return true;
  }

  void _resendOtp() {
    if (!_canResend) return;
    context.read<AuthCubit>().sendOtp(widget.phoneNumber);
  }

  void _clearAndRefocus() {
    _pinController.clear();
    _focusNode.requestFocus();
  }

  // void getAddressData() {
  //   context.read<StorageCubit>().getAddresses();
  // }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 45.w,
      height: 40.h,
      textStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: AppColors.brandPrimary,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: AppColors.brandPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: Colors.red.shade400,
          width: 2,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        backgroundColor: Colors.transparent,
        title: MyAppText(
          data: 'OTP Verification',
          color: AppColors.textPrimary,
          weight: FontWeight.w600,
          size: 14.sp,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                MyAppText(
                  data: 'Verify Your Number',
                  size: 14.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 8.h),
                MyAppText(
                  data: 'Enter the 6-digit code sent to your phone',
                  size: 12.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 20.h),
                _buildPhoneNumberCard(),
                SizedBox(height: 20.h),
                _buildOtpInputCard(defaultPinTheme, focusedPinTheme,
                    submittedPinTheme, errorPinTheme),
                SizedBox(height: 24.h),
                _buildResendCard(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberCard() {
    return Container(
      width: double.infinity,
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
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Iconsax.mobile_outline,
              color: AppColors.brandPrimary,
              size: 20.r,
            ),
          ),
          SizedBox(width: 16.w),
          MyAppText(
            data:
                '${BrandConfig.instance.content.phoneCountryCode} ${widget.phoneNumber}',
            size: 14.sp,
            weight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
            ),
            child: Row(
              children: [
                Icon(Iconsax.edit_2_bold, size: 14.r),
                SizedBox(width: 4.w),
                MyAppText(
                  data: 'Edit',
                  size: 11.sp,
                  color: AppColors.brandPrimary,
                  weight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputCard(PinTheme defaultPinTheme, PinTheme focusedPinTheme,
      PinTheme submittedPinTheme, PinTheme errorPinTheme) {
    return Container(
      width: double.infinity,
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
      padding: EdgeInsets.all(24.r),
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
                  Icons.pin_rounded,
                  color: AppColors.brandPrimary,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              MyAppText(
                data: "Enter OTP Code",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 47.w),
            child: MyAppText(
              data: "Enter the 6-digit code we sent to your phone",
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Center(
            child: Pinput(
              controller: _pinController,
              focusNode: _focusNode,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              errorPinTheme: errorPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              cursor: Container(
                width: 2.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              onCompleted: (pin) => _verifyOtp(),
              onChanged: (value) => setState(() {}),
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
          ),
          SizedBox(height: 24.h),
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is VerifyOTPLoading) {
                setState(() => _isLoading = true);
              } else if (state is VerifyOTPSuccess) {
                setState(() => _isLoading = false);

                if (state.data.isAlreadyRegistered != true) {
                  context.read<StorageCubit>().setIsGuestMode(null);
                  context.go("/name-screen",
                      extra: {"phoneNumber": widget.phoneNumber});
                } else {
                  UserDetail userData = UserDetail(
                    email: state.data.userEmail,
                    isVerified: true,
                    name: state.data.userName,
                    phoneNumber: widget.phoneNumber,
                    customerID: state.data.userId.toString(),
                  );
                  context.read<StorageCubit>().setUserData(userData);
                  context.read<StorageCubit>().setIsGuestMode(false);
                  loadUserAppData(context, userData.customerID.toString());
                }
              } else if (state is VerifyOTPError) {
                setState(() => _isLoading = false);
                myAppSnackError(state.message, context);
                _clearAndRefocus();
              } else if (state is SendOTPSuccess) {
                myAppSnackSuccess('OTP has been resent!', context);
                _startTimer();
                _clearAndRefocus();
              } else if (state is SendOTPError) {
                myAppSnackError(state.message, context);
              } else if (state is ListAddressLoading) {
                setState(() => _isLoading = true);
              } else if (state is ListAddressSuccess) {
                setState(() => _isLoading = false);

                context.read<StorageCubit>().getAddress();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  context.pushReplacement('/bottom-bar');
                });
              } else if (state is ListAddressError) {
                setState(() => _isLoading = false);

                context.read<StorageCubit>().getAddress();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  context.pushReplacement('/bottom-bar');
                });
              }
            },
            builder: (context, state) {
              return MyAppButton(
                loading: _isLoading,
                label: "VERIFY OTP",
                fontSize: 12.sp,
                imageSize: 14.r,
                backgroundColor: AppColors.brandPrimary,
                onPressed: _verifyOtp,
                borderRadius: 16,
                icon: Icons.check_circle_outline_rounded,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResendCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: _canResend
                      ? AppColors.brandPrimary.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: _canResend
                      ? AppColors.brandPrimary
                      : AppColors.textSecondary,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppText(
                      data: _canResend
                          ? 'Didn\'t receive the code?'
                          : 'Waiting for OTP',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    MyAppText(
                      data: _canResend
                          ? 'You can request a new code'
                          : 'Resend available in $_remainingSeconds seconds',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_canResend) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is SendOTPLoading) {
                    setState(() => _isLoading = true);
                  } else if (state is SendOTPSuccess) {
                    setState(() => _isLoading = false);
                    myAppSnackSuccess('OTP has been resent!', context);
                    _startTimer();
                    _clearAndRefocus();
                  } else if (state is SendOTPError) {
                    setState(() => _isLoading = false);
                    myAppSnackError(state.message, context);
                  }
                },
                builder: (context, state) {
                  return TextButton(
                    onPressed: _resendOtp,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary.withOpacity(0.1),
                      foregroundColor: AppColors.brandPrimary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 18.r),
                        SizedBox(width: 8.w),
                        MyAppText(
                          data: 'Resend OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}


