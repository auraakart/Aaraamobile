import 'package:aaraa_kart/app/router/app_routes.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_state.dart';
import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class ScheduleFutureDeliverySheet extends StatefulWidget {
  final DateTime? initialDate;
  final VoidCallback? onFutureDeliveryCreated;

  const ScheduleFutureDeliverySheet({
    super.key,
    this.initialDate,
    this.onFutureDeliveryCreated,
  });

  static Future<void> show(
    BuildContext context, {
    DateTime? initialDate,
    VoidCallback? onFutureDeliveryCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleFutureDeliverySheet(
        initialDate: initialDate,
        onFutureDeliveryCreated: onFutureDeliveryCreated,
      ),
    );
  }

  @override
  State<ScheduleFutureDeliverySheet> createState() =>
      _ScheduleFutureDeliverySheetState();
}

class _ScheduleFutureDeliverySheetState
    extends State<ScheduleFutureDeliverySheet> {
  Product? _selectedProduct;
  int _quantity = 1;
  late DateTime _selectedDate;
  DeliverySlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    if (widget.initialDate != null && !widget.initialDate!.isBefore(tomorrow)) {
      _selectedDate = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
      );
    } else {
      _selectedDate = tomorrow;
    }

    final productState = context.read<ProductCubit>().state;
    if (productState is ProductSuccess) {
      if (productState.products.isNotEmpty) {
        _selectedProduct = productState.products.first;
      }
      if (productState.deliverySlots != null &&
          productState.deliverySlots!.isNotEmpty) {
        _selectedSlot = productState.deliverySlots!.first;
      }
    } else {
      context.read<ProductCubit>().getProducts(1, 20, null);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(tomorrow) ? tomorrow : _selectedDate,
      firstDate: tomorrow,
      lastDate: today.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.textPrimary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final normalizedPicked = DateTime(picked.year, picked.month, picked.day);
      if (!normalizedPicked.isBefore(tomorrow)) {
        setState(() {
          _selectedDate = normalizedPicked;
        });
      }
    }
  }

  void _submitFutureDelivery() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    final product = _selectedProduct!;
    final productId = product.id.toString();
    final images = product.images;
    final price = product.price?.toString() ??
        product.regularPrice?.toString() ??
        '0';
    final imageUrl = (images != null && images.isNotEmpty)
        ? images.first.src.toString()
        : '';

    final deliveryDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final slotLabel = _selectedSlot?.label ??
        _selectedSlot?.name ??
        _selectedSlot?.timeLabel ??
        'Morning (6:00 AM - 8:00 AM)';

    context.read<CartCubit>().addItemQuantity(
          CartItem(
            id: productId,
            name: product.name.toString(),
            price: price,
            quantity: _quantity,
            imageUrl: imageUrl,
            deliveryDate: deliveryDateStr,
            deliverySlot: slotLabel,
          ),
          context,
        );

    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.push(AppRoutes.cart.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header handle & title
              _buildHeader(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Select Product
                    _buildSectionTitle('Select Product', Iconsax.box_outline),
                    SizedBox(height: 8.h),
                    _buildProductSelector(),

                    SizedBox(height: 18.h),

                    // 2. Quantity
                    _buildSectionTitle('Quantity', Iconsax.add_circle_outline),
                    SizedBox(height: 8.h),
                    _buildQuantitySelector(),

                    SizedBox(height: 18.h),

                    // 3. Delivery Date
                    _buildSectionTitle(
                        'Delivery Date', Iconsax.calendar_1_outline),
                    SizedBox(height: 8.h),
                    _buildDateSelector(),

                    SizedBox(height: 18.h),

                    // 4. Delivery Slot
                    _buildSectionTitle('Delivery Slot', Iconsax.clock_outline),
                    SizedBox(height: 8.h),
                    _buildSlotSelector(),

                    SizedBox(height: 24.h),

                    // 5. Confirm Button
                    MyAppButton(
                      label: 'Add to Cart',
                      backgroundColor: AppColors.textPrimary,
                      onPressed: _submitFutureDelivery,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Container(
            width: 38.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppText(
                    data: 'Schedule Future Delivery',
                    size: 16.sp,
                    weight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 2.h),
                  MyAppText(
                    data: 'Add a one-time delivery for a specific date',
                    size: 11.5.sp,
                    weight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close,
                    size: 20.sp, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.borderDefault),
        SizedBox(height: 14.h),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textPrimary),
        SizedBox(width: 6.w),
        MyAppText(
          data: title,
          size: 12.5.sp,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildProductSelector() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        List<Product> products = [];
        if (state is ProductSuccess) {
          products = state.products;
          if (_selectedProduct == null && products.isNotEmpty) {
            _selectedProduct = products.first;
          }
        }

        if (products.isEmpty) {
          return Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10.w),
                MyAppText(
                  data: 'Loading products...',
                  size: 11.5.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 90.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final prod = products[index];
              final isSelected = _selectedProduct?.id == prod.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedProduct = prod;
                  });
                },
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: 200.w,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.borderDefault,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSurface,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: prod.images?.isNotEmpty == true
                            ? MyAppCachedImage(
                                imageUrl: prod.images!.first.src.toString(),
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                Iconsax.box_outline,
                                size: 18.sp,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.brandPrimary,
                              ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyAppText(
                              data: prod.name ?? '',
                              size: 12.sp,
                              weight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 3.h),
                            MyAppText(
                              data:
                                  '₹${prod.price ?? prod.regularPrice ?? "0"}',
                              size: 12.sp,
                              weight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.brandPrimaryDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyAppText(
            data: 'Quantity (Items)',
            size: 12.sp,
            weight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          Row(
            children: [
              InkWell(
                onTap: _quantity > 1
                    ? () {
                        setState(() {
                          _quantity--;
                        });
                      }
                    : null,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16.sp,
                    color: _quantity > 1
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              MyAppText(
                data: '$_quantity',
                size: 14.sp,
                weight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 14.w),
              InkWell(
                onTap: () {
                  setState(() {
                    _quantity++;
                  });
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.calendar_outline,
              size: 18.sp,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: MyAppText(
                data: formattedDate,
                size: 12.5.sp,
                weight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: MyAppText(
                data: 'Change',
                size: 11.sp,
                weight: FontWeight.w600,
                color: AppColors.brandPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSelector() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        List<DeliverySlot> slots = [];
        if (state is ProductSuccess &&
            state.deliverySlots != null &&
            state.deliverySlots!.isNotEmpty) {
          slots = state.deliverySlots!;
        } else {
          slots = [
            DeliverySlot(id: 1, name: 'Morning (6:00 AM - 8:00 AM)'),
            DeliverySlot(id: 2, name: 'Evening (5:00 PM - 7:00 PM)'),
          ];
        }

        if (_selectedSlot == null && slots.isNotEmpty) {
          _selectedSlot = slots.first;
        }

        return Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: slots.map((slot) {
            final isSelected = _selectedSlot?.id == slot.id;
            final label = slot.label ?? slot.name ?? slot.timeLabel ?? 'Slot';

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedSlot = slot;
                });
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.borderDefault,
                  ),
                ),
                child: MyAppText(
                  data: label,
                  size: 11.5.sp,
                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
