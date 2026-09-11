import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/utils/get_initials.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  bool _isLoading = false;
  UserDetail? userData;

  @override
  void initState() {
    super.initState();
    userData = context.read<StorageCubit>().userData;
    _initializeFields();
  }

  _initializeFields() {
    if (userData != null) {
      _nameController.text = userData!.name ?? '';
      _emailController.text = userData!.email ?? '';
      _phoneController.text = userData!.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        title: MyAppText(
          data: 'View Profile',
          color: AppColors.textPrimary,
          weight: FontWeight.bold,
          size: 16.sp,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              // _buildProfileHeader(),
              // SizedBox(height: 24.h),
              _buildPersonalInfoSection(),
              SizedBox(height: 20.h),
              // _buildContactInfoSection(),
              // SizedBox(height: 20.h),
              // _buildSaveButton(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
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
        children: [
          Stack(
            children: [
              Container(
                height: 80.h,
                width: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 35.r,
                    backgroundColor: AppColors.brandPrimary.withOpacity(0.8),
                    child: MyAppText(
                      data: getInitials(_nameController.text.toString()),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Photo upload coming soon!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.brandPrimary,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          MyAppText(
            data: 'Update Profile Picture',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        MyAppTextField(
          enabled: false,
          controller: _nameController,
          hintText: "Enter your full name",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.person_outline,
              color: AppColors.brandPrimary,
              size: 14.r,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        MyAppTextField(
          enabled: false,
          controller: _phoneController,
          hintText: "Mobile Number",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Iconsax.call_bold,
              color: AppColors.brandPrimary,
              size: 14.r,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        MyAppTextField(
          enabled: false,
          controller: _emailController,
          hintText: "Enter your email address",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.email_outlined,
              color: AppColors.brandPrimary,
              size: 14.r,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.phone_outlined,
      children: [
        MyAppTextField(
          controller: _phoneController,
          hintText: "Enter your mobile number",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.phone_android_rounded,
              color: AppColors.brandPrimary,
              size: 14.r,
            ),
          ),
          prefixText: "+91 ",
          isNumber: true,
          maxLength: 10,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
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
                  icon,
                  color: AppColors.brandPrimary,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              MyAppText(
                data: title,
                color: AppColors.textPrimary,
                size: 12.sp,
                weight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return MyAppButton(
      loading: _isLoading,
      label: "SAVE CHANGES",
      onPressed: _saveProfile,
      icon: Icons.check_rounded,
    );
  }

  void _saveProfile() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your full name');
      return;
    }

    if (_emailController.text.trim().isNotEmpty &&
        !_isValidEmail(_emailController.text.trim())) {
      _showErrorSnackBar('Please enter a valid email address');
      return;
    }

    if (_phoneController.text.length != 10) {
      _showErrorSnackBar('Please enter a valid mobile number');
      return;
    }

    if (_pincodeController.text.trim().isNotEmpty &&
        _pincodeController.text.length != 6) {
      _showErrorSnackBar('Please enter a valid pincode');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // // Update user data in singleton (in real app, this would come from API response)
      // if (userData != null) {
      //   // Create updated user data
      //   UserDetail updatedUser = UserDetail(
      //     id: userData!.id,
      //     name: _nameController.text.trim(),
      //     email: _emailController.text.trim(),
      //     phone: _phoneController.text.trim(),
      //     address: _addressController.text.trim(),
      //     pincode: _pincodeController.text.trim(),
      //   );

      //   AppSingleton().setUserData(updatedUser);
      // }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );

      context.pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar('Failed to update profile. Please try again.');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }
}


