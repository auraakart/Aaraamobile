import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/auth/auth_state.dart';
import 'package:aaraa_kart/cubit/google_maps/maps_cubit.dart';
import 'package:aaraa_kart/cubit/google_maps/maps_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showAddressDetailsBottomSheet({
  required BuildContext context,
  required String location,
  required String pincode,
}) {
  final formKey = GlobalKey<FormState>();
  final userData = context.read<StorageCubit>().userData;
  final addressParts = location.split(',');

  final TextEditingController nameController =
      TextEditingController(text: userData?.name ?? '');
  final TextEditingController phoneController =
      TextEditingController(text: userData?.phoneNumber ?? '');
  final TextEditingController addressController = TextEditingController(
    text: addressParts.first.trim(),
  );
  final TextEditingController address2Controller = TextEditingController(
    text: addressParts.length > 1 ? addressParts[1].trim() : '',
  );
  final TextEditingController landmarkController = TextEditingController();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        address2Controller.text.isNotEmpty) {
      context.read<MapsCubit>().validateConfirmAddressButton(true);
    }
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      int addressType = 0;
      void showError(BuildContext context, String message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }

      void handleAddressConfirmation(
        BuildContext context,
        List<GetAddressResponse>? addressData,
      ) {
        try {
          final userData = context.read<StorageCubit>().userData;
          if (userData == null) {
            showError(context, 'User data not available');
            return;
          }

          if (nameController.text.trim().isEmpty) {
            showError(context, 'Please enter a name');
            return;
          }

          if (phoneController.text.trim().isEmpty) {
            showError(context, 'Please enter a phone number');
            return;
          }

          final int? phoneNumber = int.tryParse(phoneController.text.trim());
          if (phoneNumber == null) {
            showError(context, 'Please enter a valid phone number');
            return;
          }

          const addressTypeLabels = ['Home', 'Work', 'Other'];

          final GetAddressResponse newAddress = GetAddressResponse(
            customerId:
                int.tryParse(userData.customerID?.toString() ?? '') ?? 0,
            name: nameController.text.trim(),
            mobileNumber: phoneNumber.toString(),
            label: addressTypeLabels[addressType],
            address1: addressController.text.trim(),
            address2: address2Controller.text.trim(),
            landmark: landmarkController.text.trim(),
            city: "Chennai",
            state: "TN",
            postcode: pincode,
            country: "India",
            isPrimary: addressData!.isEmpty ? 1 : 0,
          );

          context.read<AuthCubit>().addAddress(newAddress);
        } catch (e) {
          showError(context, 'Failed to add address: ${e.toString()}');
        }
      }

      return StatefulBuilder(builder: (context, setModalState) {
        void submitButton() {
          if (nameController.text.isNotEmpty &&
              phoneController.text.isNotEmpty &&
              addressController.text.isNotEmpty &&
              address2Controller.text.isNotEmpty) {
            context.read<MapsCubit>().validateConfirmAddressButton(true);
          } else {
            context.read<MapsCubit>().validateConfirmAddressButton(false);
          }
        }

        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.w),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyAppText(
                              data: 'Enter Complete Address',
                              size: 14.sp,
                              weight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: AppColors.textSecondary),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(16.r),
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: AppColors.brandPrimary, size: 14.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: MyAppText(
                                    data: 'Selected Location',
                                    weight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    size: 12.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_location_alt,
                                        size: 12.r,
                                        color: AppColors.brandPrimary,
                                      ),
                                      SizedBox(width: 4.w),
                                      MyAppText(
                                        data: 'Change',
                                        weight: FontWeight.w600,
                                        color: AppColors.brandPrimary,
                                        size: 10.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            MyAppText(
                              data: location,
                              color: Colors.grey.shade700,
                              size: 10.sp,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.r),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyAppText(
                            data: 'Receiver Details',
                            size: 14.sp,
                            weight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(height: 12.h),
                          MyAppTextField(
                            controller: nameController,
                            hintText: 'Name *',
                            onChanged: (p0) => submitButton(),
                          ),
                          SizedBox(height: 12.h),
                          MyAppTextField(
                            controller: phoneController,
                            hintText: 'Phone Number *',
                            prefixText:
                                "${BrandConfig.instance.content.phoneCountryCode} ",
                            isNumber: true,
                            maxLength: 10,
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyAppText(
                                data: 'Address Details',
                                size: 14.sp,
                                weight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          MyAppTextField(
                            controller: addressController,
                            hintText: 'Flat/House/Floor/Building *',
                            onChanged: (p0) => submitButton(),
                          ),
                          SizedBox(height: 12.h),
                          MyAppTextField(
                            controller: address2Controller,
                            hintText: 'Area/Street/Locality *',
                            onChanged: (p0) => submitButton(),
                          ),
                          SizedBox(height: 12.h),
                          MyAppTextField(
                            controller: landmarkController,
                            hintText: 'Nearby Landmark (Optional)',
                            onChanged: (p0) => submitButton(),
                          ),
                          SizedBox(height: 16.h),
                          MyAppText(
                            data: 'Save Address as',
                            size: 14.sp,
                            weight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              _buildAddressTypeChip(
                                  context, 'Home', addressType == 0, () {
                                setModalState(() {
                                  addressType = 0;
                                });
                              }),
                              SizedBox(width: 12.w),
                              _buildAddressTypeChip(
                                  context, 'Work', addressType == 1, () {
                                setModalState(() {
                                  addressType = 1;
                                });
                              }),
                              SizedBox(width: 12.w),
                              _buildAddressTypeChip(
                                  context, 'Other', addressType == 2, () {
                                setModalState(() {
                                  addressType = 2;
                                });
                              }),
                            ],
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  ),
                ),

                BlocConsumer<StorageCubit, StorageState>(
                  listener: (context, state) {},
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    final List<GetAddressResponse> addressData =
                        context.read<StorageCubit>().state.addressData;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: BlocBuilder<MapsCubit, MapsState>(
                        buildWhen: (previous, current) => previous != current,
                        builder: (context, mapsState) {
                          return BlocConsumer<AuthCubit, AuthState>(
                            listener: (context, authState) {
                              if (authState is CreateAddressSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Address added successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                context.read<StorageCubit>().getAddress();

                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              } else if (authState is CreateAddressError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error: ${authState.message}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            builder: (context, firebaseState) {
                              return MyAppButton(
                                loading:
                                    firebaseState is CreateAddressLoading &&
                                        firebaseState.isLoading,
                                isDisabled: !(mapsState
                                        is ValidateConfirmAddressState &&
                                    mapsState.isValid),
                                onPressed: () => handleAddressConfirmation(
                                    context, addressData),
                                label: 'Confirm Address',
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      });
    },
  );
}

Widget _buildAddressTypeChip(
  BuildContext context,
  String label,
  bool isSelected,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.brandPrimary : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? AppColors.brandPrimary
              : AppColors.brandPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: MyAppText(
        data: label,
        color: isSelected ? Colors.white : AppColors.textPrimary,
        weight: isSelected ? FontWeight.bold : FontWeight.w500,
        size: 12.sp,
      ),
    ),
  );
}


