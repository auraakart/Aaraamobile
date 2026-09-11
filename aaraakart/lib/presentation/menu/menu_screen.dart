import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/app/utils/get_initials.dart';
import 'package:aaraa_kart/app/utils/logout_helper.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/user_detail_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_icon_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/whatsapp_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  UserDetail? userData;
  bool _isLoaderVisible = false;

  @override
  void initState() {
    userData = context.read<StorageCubit>().userData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is DeleteCustomerLoading && state.isLoading) {
          if (!_isLoaderVisible) {
            _isLoaderVisible = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          }
        }

        if (state is DeleteCustomerSuccess) {
          if (_isLoaderVisible) {
            Navigator.of(context, rootNavigator: true).pop();
            _isLoaderVisible = false;
          }

          performLogout(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          context.pushReplacement('/login');
        }

        if (state is DeleteCustomerError) {
          if (_isLoaderVisible) {
            Navigator.of(context, rootNavigator: true).pop();
            _isLoaderVisible = false;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    final isGuest = context.read<StorageCubit>().isGuestMode == true;

    return Scaffold(
      appBar: MyAppBar(
        showLeading: true,
        centerTitle: false,
        title: const MyAppText(data: 'Menu'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            isGuest ? _buildGuestCard() : _buildUserProfileCard(),
            _buildSectionDivider(isGuest ? 'Support & Information' : 'Account'),
            if (!isGuest)
              _buildListItem(
                context,
                icon: Iconsax.location_bold,
                title: 'Saved Address',
                subtitle: 'Your delivery addresses',
                onTap: () => context.push("/location-selection"),
              ),
            _buildListItem(
              context,
              icon: Iconsax.message_2_bold,
              title: 'FAQ',
              subtitle: 'Frequently asked questions',
              onTap: () => context.push('/faq-screen'),
            ),
            _buildListItem(
              context,
              icon: Iconsax.note_2_bold,
              title: 'Terms and Conditions',
              subtitle: 'Our terms of service',
              onTap: () => context.push('/tnc'),
            ),
            _buildListItem(
              context,
              icon: Iconsax.lock_circle_bold,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () => context.push('/privacy'),
            ),
            _buildListItem(
              context,
              icon: Iconsax.call_outgoing_bold,
              title: 'Contact Us',
              subtitle: 'Get in touch with our team',
              onTap: () => handleWhatsAppLauncher(
                  BrandConfig.instance.content.whatsappNumber, 'Hi', context),
            ),
            _buildSectionDivider('Other'),
            if (isGuest)
              _buildListItem(
                context,
                icon: Iconsax.logout_1_bold,
                title: 'Exit Guest Mode',
                subtitle: 'Return to login screen',
                iconColor: AppColors.brandPrimary,
                titleColor: AppColors.brandPrimary,
                onTap: () {
                  context.read<StorageCubit>().setIsGuestMode(false);
                  context.pushReplacement('/login');
                },
              )
            else ...[
              _buildListItem(
                context,
                icon: Iconsax.profile_delete_bold,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                iconColor: Colors.redAccent,
                titleColor: Colors.redAccent,
                onTap: _confirmDeleteAccount,
              ),
              _buildListItem(
                context,
                icon: Iconsax.logout_1_bold,
                title: 'Logout',
                subtitle: 'Sign out from your account',
                iconColor: Colors.redAccent,
                titleColor: Colors.redAccent,
                onTap: () {
                  performLogout(context);
                  context.pushReplacement('/login');
                },
              ),
            ],
            SizedBox(height: 24.h),
            MyAppText(
              data: 'App Version 1.0.0',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final controller = TextEditingController();
    final isValid = ValueNotifier(false);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is permanent.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'All your data, orders, and profile information will be permanently deleted and cannot be recovered.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Warning box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Type DELETE below to confirm.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ValueListenableBuilder<bool>(
              valueListenable: isValid,
              builder: (_, __, ___) {
                return TextField(
                  controller: controller,
                  onChanged: (value) =>
                      isValid.value = value.trim() == 'DELETE',
                  decoration: InputDecoration(
                    hintText: 'Type DELETE',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isValid,
            builder: (_, valid, __) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      valid ? Colors.redAccent : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  elevation: valid ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: valid ? () => Navigator.pop(context, true) : null,
                child: const Text('Delete Permanently'),
              );
            },
          ),
        ],
      ),
    );

    if (confirm == true && userData?.customerID != null) {
      context.read<AuthCubit>().deleteProfileCustomer(
            userData!.customerID!,
          );
    }
  }

  Widget _buildGuestCard() {
    return Container(
      margin: EdgeInsets.all(12.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.brandPrimary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          const Expanded(child: MyAppText(data: 'Guest User')),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      margin: EdgeInsets.all(12.r),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Double Circle Avatar
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandPrimary.withOpacity(0.15), // outer circle
            ),
            alignment: Alignment.center,
            child: Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary, // inner circle
              ),
              alignment: Alignment.center,
              child: MyAppText(
                data: getInitials(userData?.name),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(width: 14.w),

          /// Name + Customer ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyAppText(
                  data: userData?.name?.toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),

                /// Customer ID chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: MyAppText(
                    data: "Customer ID: ${userData?.customerID ?? '--'}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Edit Profile Button
          InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              context.push('/edit-profile');
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.arrow_right_bold,
                    size: 18.sp,
                    color: AppColors.brandPrimary,
                  ),
                  // SizedBox(width: 6.w),
                  // MyAppText(
                  //   data: "Edit",
                  //   style: TextStyle(
                  //     fontSize: 13.sp,
                  //     color: AppColors.brandPrimary,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          MyAppText(
            data: title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(child: Divider(color: AppColors.borderDefault)),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: MyAppIconButton(
          variant: "color",
          icon: icon,
          onPressed: () {},
          iconColor: iconColor ?? AppColors.brandPrimaryDark,
        ),
        title: MyAppText(
          data: title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: MyAppText(
          data: subtitle,
          style: TextStyle(fontSize: 10.sp),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14.sp,
          color: AppColors.brandPrimary,
        ),
        onTap: onTap,
      ),
    );
  }
}


