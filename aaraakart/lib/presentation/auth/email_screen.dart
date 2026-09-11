import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/utils/post_login_loader.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/user_create_request.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EmailScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;

  const EmailScreen({
    super.key,
    required this.phoneNumber,
    required this.name,
  });

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.push("/login"),
        ),
        title: Text(
          'Email Information',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Hi ${widget.name}!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll use this to send you order updates and exclusive offers',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brandSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            color: AppColors.brandSecondary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        "We'll send order updates and exclusive offers here",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyAppTextField(
                      controller: _emailController,
                      hintText: "Enter your email address",
                      isNumber: false,
                    ),
                    const SizedBox(height: 32),
                    buildContinueButton(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  buildContinueButton() => BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is CreateCustomerSuccess) {
            if (state.data!.id != null) {
              UserDetail userData = UserDetail(
                email: _emailController.text.trim(),
                isVerified: true,
                name: widget.name,
                phoneNumber: widget.phoneNumber,
                customerID: state.data!.id.toString(),
              );

              context.read<StorageCubit>().setIsGuestMode(false);
              context.read<StorageCubit>().setUserData(userData);
              loadUserAppData(context, userData.customerID.toString());

              context.pushReplacement('/welcome', extra: {
                'name': widget.name,
                'phoneNumber': widget.phoneNumber,
                'email': _emailController.text.trim(),
              });
            }
          } else if (state is CreateCustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.red.shade600,
                margin: const EdgeInsets.all(10),
              ),
            );
          }
        },
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          return state is CreateCustomerLoading && state.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brandPrimary,
                  ),
                )
              : MyAppButton(
                  label: "COMPLETE REGISTRATION",
                  backgroundColor: AppColors.brandPrimary,
                  onPressed: _completeRegistration,
                  borderRadius: 16,
                  icon: Icons.check_circle_outline_rounded,
                );
        },
      );

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _completeRegistration() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red.shade600,
          margin: const EdgeInsets.all(10),
        ),
      );
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red.shade600,
          margin: const EdgeInsets.all(10),
        ),
      );
      return;
    }

    BlocProvider.of<AuthCubit>(context).createCustomer(UserCreateRequest(
      email: _emailController.text.trim(),
      firstName: widget.name,
      username: widget.name,
      password: widget.phoneNumber,
      billing: UserCreateRequestBilling(
        firstName: widget.name,
        phone: widget.phoneNumber,
      ),
      metaData: [
        UserCreateMetaDatum(
          key: 'billing_phone',
          value: widget.phoneNumber,
        ),
        UserCreateMetaDatum(
          key: 'xoo_ml_phone_code',
          value: BrandConfig.instance.content.phoneCountryCode,
        ),
        UserCreateMetaDatum(
          key: 'xoo_ml_phone_no',
          value: widget.phoneNumber,
        ),
        UserCreateMetaDatum(
          key: 'xoo_ml_phone_display',
          value: '91${widget.phoneNumber}',
        ),
      ],
    ));
  }
}


