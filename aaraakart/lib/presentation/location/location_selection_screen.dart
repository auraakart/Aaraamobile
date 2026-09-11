import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_dialog.dart';
import 'package:aaraa_kart/presentation/common/my_app_icon_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/bottom_button_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({
    super.key,
  });

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  List<GetAddressResponse>? _savedAddresses = [];
  String? _updatingAddressId;
  String? _deletingAddressId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshAddresses() async {
    final customerId = context.read<StorageCubit>().userData?.customerID;
    if (customerId == null || customerId.isEmpty) return;
    await context.read<AuthCubit>().listAddress(customerId);
    await context.read<StorageCubit>().getAddress();
  }

  void _updateAddress(
      String addressId, String customerId, String billingName) async {
    setState(() {
      _updatingAddressId = addressId;
    });

    context.read<AuthCubit>().updateAddress(
          addrID: addressId,
          userId: customerId,
        );
  }

  void _removeAddress(String addressId, String customerId) async {
    setState(() {
      _deletingAddressId = addressId;
    });

    context
        .read<AuthCubit>()
        .deleteAddress(addrID: addressId, userId: customerId);
  }

  void _confirmSelection() {}

  void _editAddress(int index) {
    // Navigate to edit address screen
    context.push('/edit-address', extra: _savedAddresses![index]);
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.location_slash_bold,
                  size: 64.r,
                  color: AppColors.brandPrimary.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 24.h),
              MyAppText(
                data: 'No Saved Addresses',
                size: 18.sp,
                weight: FontWeight.bold,
                color: AppColors.brandPrimaryDark,
              ),
              SizedBox(height: 12.h),
              MyAppText(
                data:
                    'You haven\'t added any delivery addresses yet.\nAdd your first address to get started.',
                size: 14.sp,
                color: AppColors.textSecondary,
                align: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              context.read<StorageCubit>().isGuestMode != false
                  ? MyAppButton(
                      onPressed: () {
                        context.push('/login', extra: {
                          'guestMode': true,
                        });
                      },
                      label: 'Sign In to Proceed',
                      icon: Iconsax.lock_outline,
                    )
                  : MyAppButton(
                      onPressed: () => context.push('/google-maps'),
                      label: "Add Your First Address",
                      icon: Icons.add_location_alt_rounded,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: false,
        title: MyAppText(
          data: 'Select Address',
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is UpdateAddressSuccess) {
                context.read<StorageCubit>().getAddress();
                setState(() {
                  _updatingAddressId = null;
                });
                // Show success message if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Address updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is UpdateAddressError) {
                setState(() {
                  _updatingAddressId = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is DeleteAddressSuccess) {
                context.read<StorageCubit>().getAddress();

                setState(() {
                  _deletingAddressId = null;
                });
                // Show success message if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Address deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is DeleteAddressError) {
                setState(() {
                  _deletingAddressId = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: _refreshAddresses,
          color: AppColors.brandPrimary,
          child: BlocBuilder<StorageCubit, StorageState>(
            builder: (context, state) {
              _savedAddresses = state.addressData;
              return Column(
                children: [
                  Expanded(
                    child: _savedAddresses!.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _savedAddresses!.length,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemBuilder: (context, index) {
                              final address = _savedAddresses![index];
                              final isSelected = address.isPrimary == 1;
                              final isUpdating =
                                  _updatingAddressId == address.id?.toString();
                              final isDeleting =
                                  _deletingAddressId == address.id?.toString();

                              return Container(
                                margin: EdgeInsets.only(
                                    top: index == 0 ? 16 : 0, bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected == true
                                      ? Border.all(
                                          color: AppColors.brandPrimary,
                                          width: 0.5,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16.r),
                                  onTap: isUpdating || isDeleting
                                      ? null
                                      : () => _updateAddress(
                                            (address.id ?? 0).toString(),
                                            address.customerId.toString(),
                                            address.name!,
                                          ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.r),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyAppIconButton(
                                          icon: address.label == 'Home'
                                              ? Iconsax.home_2_bold
                                              : address.label == 'Work'
                                                  ? Iconsax.briefcase_bold
                                                  : Iconsax.location_bold,
                                          variant: 'color',
                                          onPressed: () {},
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                spacing: 20.w,
                                                children: [
                                                  MyAppText(
                                                    data: address.label ??
                                                        "Other",
                                                    size: 14.sp,
                                                    weight: FontWeight.w600,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                  if (isSelected == true)
                                                    InkWell(
                                                      onTap: () {},
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.r),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12.w,
                                                          vertical: 3.h,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .brandPrimary
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.r),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            MyAppText(
                                                              data: 'Default',
                                                              size: 10.sp,
                                                              weight: FontWeight
                                                                  .w500,
                                                              color: AppColors
                                                                  .brandPrimary,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 6.h),
                                              MyAppText(
                                                data: address.name ?? '',
                                                size: 11.sp,
                                                color: Colors.grey.shade600,
                                                weight: FontWeight.bold,
                                              ),
                                              SizedBox(height: 6.h),
                                              MyAppText(
                                                data:
                                                    '${address.address1 ?? ''} - ${address.address2 ?? ''}',
                                                size: 10.sp,
                                                color: Colors.grey.shade600,
                                                maxLines: 3,
                                              ),
                                              SizedBox(height: 8.h),
                                              MyAppText(
                                                data:
                                                    address.mobileNumber ?? '',
                                                size: 10.sp,
                                                color: AppColors.textPrimary,
                                                weight: FontWeight.bold,
                                              ),
                                              SizedBox(height: 12.h),
                                              Row(
                                                children: [
                                                  if (isUpdating)
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 12.w,
                                                        vertical: 6.h,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width: 16.r,
                                                            height: 16.r,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2.r,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      AppColors
                                                                          .brandPrimary),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8.w),
                                                          MyAppText(
                                                            data: 'Updating...',
                                                            size: 10.sp,
                                                            weight:
                                                                FontWeight.w500,
                                                            color: AppColors
                                                                .brandPrimaryDark,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  else if (isDeleting)
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 12.w,
                                                        vertical: 6.h,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width: 16.r,
                                                            height: 16.r,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2.r,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .red),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8.w),
                                                          MyAppText(
                                                            data: 'Deleting...',
                                                            size: 10.sp,
                                                            weight:
                                                                FontWeight.w500,
                                                            color: Colors.red,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  else if (isSelected != true)
                                                    InkWell(
                                                      onTap: () => showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            MyAppDialog(
                                                          title:
                                                              "Delete Address",
                                                          subtitle:
                                                              "Are you sure you want to delete this address?",
                                                          positiveText: "Yes",
                                                          negativeText: "No",
                                                          onPositivePressed:
                                                              () {
                                                            _removeAddress(
                                                                (address.id ??
                                                                        0)
                                                                    .toString(),
                                                                address
                                                                    .customerId
                                                                    .toString());
                                                            context.pop();
                                                          },
                                                          onNegativePressed:
                                                              () {
                                                            context.pop();
                                                          },
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.r),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 12.w,
                                                          vertical: 6.h,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .red.shade50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.r),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Iconsax
                                                                  .trash_bold,
                                                              size: 14.r,
                                                              color: Colors
                                                                  .red.shade400,
                                                            ),
                                                            SizedBox(
                                                                width: 4.w),
                                                            MyAppText(
                                                              data: 'Delete',
                                                              size: 10.sp,
                                                              weight: FontWeight
                                                                  .w500,
                                                              color: Colors
                                                                  .red.shade400,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(2.r),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected == true
                                                  ? AppColors.brandPrimary
                                                  : Colors.grey.shade300,
                                              width: 2,
                                            ),
                                          ),
                                          child: Container(
                                            width: 12.r,
                                            height: 12.r,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected == true
                                                  ? AppColors.brandPrimary
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<StorageCubit, StorageState>(
        builder: (context, state) {
          return state.addressData.isEmpty
              ? SizedBox()
              : BottomButtonContainer(
                  widgets: [
                    SizedBox(
                      height: 10.h,
                    ),
                    MyAppButton(
                      onPressed: () => context.push('/google-maps'),
                      label: "Add New Address",
                      icon: Iconsax.location_add_outline,
                    ),
                  ],
                );
        },
      ),
    );
  }
}


