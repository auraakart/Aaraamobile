import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NameScreen extends StatefulWidget {
  final String phoneNumber;

  const NameScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          icon: Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pushReplacement("/login"),
        ),
        title: Text(
          'Personal Information',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Tell Us Your Name',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us personalize your experience with ${BrandConfig.instance.appName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
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
                              color: AppColors.brandPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.brandPrimary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      MyAppTextField(
                        controller: _nameController,
                        // focusNode: _focusNode,
                        hintText: "Enter your full name",
                        isNumber: false,
                      ),
                      const SizedBox(height: 32),
                      MyAppButton(
                        label: "CONTINUE",
                        backgroundColor: AppColors.brandPrimary,
                        onPressed: _validateAndContinue,
                        borderRadius: 16,
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your name'),
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

    if (_nameController.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid name'),
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
    context.read<StorageCubit>().setUserData(UserDetail(
          phoneNumber: widget.phoneNumber,
          isVerified: true,
          name: _nameController.text.trim(),
          email: null,
        ));
    context.go('/email-screen', extra: {
      'phoneNumber': widget.phoneNumber,
      'name': _nameController.text.trim(),
    });
  }
}


