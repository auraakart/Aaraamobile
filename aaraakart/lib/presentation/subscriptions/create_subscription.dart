import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/create_sub_checkout_route_model.dart';
import 'package:aaraa_kart/data/model/create_sub_route_model.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/product_details_response.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_icon_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class CreateSubscription extends StatefulWidget {
  final CreateSubRouteModel productDetails;

  const CreateSubscription({
    super.key,
    required this.productDetails,
  });

  @override
  State<CreateSubscription> createState() => _CreateSubscriptionState();
}

class _CreateSubscriptionState extends State<CreateSubscription> {
  ProductDetails? subProductDetails;
  int _scheduleIndex = 0;
  int _deliveryTimeIndex = 0;
  final Set<int> _selectedWeekdays = {};

  String? _selectedFrequency;
  int _selectedQuantity = 1;
  DateTime _startDate = DateTime.now().add(Duration(days: 1));

  @override
  void initState() {
    super.initState();
    final initialState = context.read<ProductCubit>().state;
    _applySelectedSchedule(_deliveryScheduleFromState(initialState));
  }

  DeliverySchedule? _deliveryScheduleFromState(ProductState state) {
    if (state is ProductSuccess) return state.deliverySchedule;
    if (state is GetProductDetailsSuccess) return state.deliverySchedule;
    return null;
  }

  DeliverySchedule? get _deliverySchedule =>
      _deliveryScheduleFromState(context.read<ProductCubit>().state);

  List<ScheduleOption> get _scheduleOptions =>
      _deliverySchedule?.schedules ?? [];

  List<Weekday> get _weekdayOptions => _deliverySchedule?.weekdays ?? [];

  List<DeliverySlot> get _deliverySlots {
    final state = context.read<ProductCubit>().state;
    if (state is ProductSuccess) return state.deliverySlots ?? [];
    if (state is GetProductDetailsSuccess) return state.deliverySlots ?? [];
    return [];
  }

  void _selectDeliveryTime(int index) {
    setState(() {
      _deliveryTimeIndex = index;
    });
  }

  String _formatSlotTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour, minute));
    } catch (_) {
      return time;
    }
  }

  String _slotStartLabel(DeliverySlot slot) {
    if (slot.startTime != null && slot.startTime!.isNotEmpty) {
      return _formatSlotTime(slot.startTime);
    }
    return slot.label ?? slot.name ?? '';
  }

  String _slotEndLabel(DeliverySlot slot) {
    if (slot.endTime != null && slot.endTime!.isNotEmpty) {
      return _formatSlotTime(slot.endTime);
    }
    return '';
  }

  String _slotDisplayText(DeliverySlot slot) {
    final start = _slotStartLabel(slot);
    final end = _slotEndLabel(slot);
    if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
    if (slot.timeLabel != null && slot.timeLabel!.isNotEmpty) {
      return slot.timeLabel!;
    }
    return slot.label ?? slot.name ?? '';
  }

  ScheduleOption? get _selectedSchedule =>
      _scheduleOptions.isNotEmpty && _scheduleIndex < _scheduleOptions.length
          ? _scheduleOptions[_scheduleIndex]
          : null;

  bool get _requiresWeekdaySelection =>
      _selectedSchedule?.requiresDays ?? false;

  void _applySelectedSchedule(DeliverySchedule? deliverySchedule) {
    final schedules = deliverySchedule?.schedules ?? [];
    final schedule = schedules.isNotEmpty && _scheduleIndex < schedules.length
        ? schedules[_scheduleIndex]
        : null;
    _selectedFrequency =
        schedule == null ? null : (schedule.label ?? schedule.key ?? '');
  }

  void _selectSchedule(int index) {
    setState(() {
      _scheduleIndex = index;
      _selectedWeekdays.clear();
      _applySelectedSchedule(
          _deliveryScheduleFromState(context.read<ProductCubit>().state));
    });
  }

  void _toggleWeekday(int value) {
    setState(() {
      if (_selectedWeekdays.contains(value)) {
        _selectedWeekdays.remove(value);
      } else {
        _selectedWeekdays.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        title: MyAppText(
          data: 'Subscription Plan',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProductHeader(),
                  _buildSubscriptionOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.all(8.r),
            child: MyAppCachedImage(
              imageUrl: widget.productDetails.image!,
              fit: BoxFit.contain,
              errorWidget: Icon(
                Icons.local_drink_rounded,
                size: 32.r,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyAppText(
                  data: widget.productDetails.productName!,
                  size: 12.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 4.h),
                MyAppText(
                  data: '₹${widget.productDetails.price} per unit',
                  size: 11.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 8.h),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [AppColors.brandPrimary, AppColors.brandPrimary],
                //       begin: Alignment.centerLeft,
                //       end: Alignment.centerRight,
                //     ),
                //     borderRadius: BorderRadius.circular(12.r),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(
                //         Icons.savings_outlined,
                //         color: Colors.white,
                //         size: 12.r,
                //       ),
                //       SizedBox(width: 4.w),
                //       MyAppText(
                //         data: 'Save 10% with subscription',
                //         color: Colors.white,
                //         size: 9.sp,
                //         weight: FontWeight.w600,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return Column(
      children: [
        _buildDeliveryScheduleSelector(),
        _buildStartDateSelector(),
        _buildQuantitySelector(),
        _buildDeliveryTimeSelector(),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.shopping_bag_outline,
                color: AppColors.brandPrimary,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              MyAppText(
                data: 'Quantity per delivery',
                size: 12.sp,
                weight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () => {
                  if (_selectedQuantity <= 1)
                    {}
                  else
                    {
                      setState(() {
                        --_selectedQuantity;
                      })
                    }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 22.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.remove,
                    size: 10.r,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              Container(
                width: 22.w,
                height: 22.h,
                alignment: Alignment.center,
                child: MyAppText(
                  data: '$_selectedQuantity',
                  size: 15.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    ++_selectedQuantity;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 22.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    size: 10.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryScheduleSelector() {
    final schedules = _scheduleOptions;
    final weekdays = _weekdayOptions;
    final showWeekdayPicker = _requiresWeekdaySelection;

    return Container(
      margin: EdgeInsets.only(bottom: 6.h, left: 16.w, right: 16.w, top: 6.h),
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
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18.r,
                  color: AppColors.brandPrimary,
                ),
                SizedBox(width: 8.w),
                MyAppText(
                  data: 'Delivery Schedule',
                  size: 12.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (schedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MyAppText(
                        data: 'No delivery schedule available for this product',
                        size: 10.sp,
                        color: AppColors.textPrimary,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(schedules.length, (index) {
                  final option = schedules[index];
                  final bool isSelected = _scheduleIndex == index;
                  final label = option.label ?? option.key ?? '';

                  return GestureDetector(
                    onTap: () => _selectSchedule(index),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandPrimary
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandPrimary
                              : AppColors.textPrimary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: MyAppText(
                        data: label,
                        size: 10.sp,
                        weight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
            if (showWeekdayPicker) ...[
              SizedBox(height: 16.h),
              MyAppText(
                data: 'Select Delivery Days',
                size: 11.sp,
                weight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.h),
              if (weekdays.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MyAppText(
                          data: 'No delivery days available for this product',
                          size: 10.sp,
                          color: AppColors.textPrimary,
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: weekdays.map((day) {
                    final value = day.value;
                    final bool isSelected =
                        value != null && _selectedWeekdays.contains(value);

                    return GestureDetector(
                      onTap: value == null ? null : () => _toggleWeekday(value),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandPrimary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.textPrimary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: MyAppText(
                          data: day.label ?? '',
                          size: 10.sp,
                          weight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.brandPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedWeekdays.isEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MyAppText(
                            data:
                                'Select at least one delivery day to continue',
                            size: 10.sp,
                            color: AppColors.textPrimary,
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeSelector() {
    final slots = _deliverySlots;

    return Container(
      margin: EdgeInsets.only(bottom: 6.h, left: 16.w, right: 16.w, top: 6.h),
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
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18.r,
                  color: AppColors.brandPrimary,
                ),
                SizedBox(width: 8.w),
                MyAppText(
                  data: 'Delivery Time',
                  size: 12.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (slots.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MyAppText(
                        data:
                            'No delivery time slots available for this product',
                        size: 10.sp,
                        color: AppColors.textPrimary,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(slots.length, (index) {
                  final slot = slots[index];
                  final bool isSelected = _deliveryTimeIndex == index;
                  final start = _slotStartLabel(slot);
                  final end = _slotEndLabel(slot);

                  return Expanded(
                    child: InkWell(
                      onTap: () => _selectDeliveryTime(index),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandPrimary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.textPrimary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyAppText(
                              data: start.isNotEmpty
                                  ? start
                                  : (slot.label ?? slot.name ?? ''),
                              size: 10.sp,
                              weight: FontWeight.bold,
                              align: TextAlign.center,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            if (end.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              MyAppText(
                                data: 'to',
                                size: 10.sp,
                                align: TextAlign.center,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(height: 2.h),
                              MyAppText(
                                data: end,
                                size: 10.sp,
                                weight: FontWeight.bold,
                                align: TextAlign.center,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.calendar_1_outline,
                color: AppColors.brandPrimary,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              MyAppText(
                data: 'Subscription Start Date',
                size: 12.sp,
                weight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now().add(Duration(days: 1)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null && picked != _startDate) {
                setState(() {
                  _startDate = picked;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.brandPrimary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  MyAppText(
                    data:
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    size: 12.sp,
                    weight: FontWeight.w600,
                    color: AppColors.brandPrimary,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Icon(
                    Icons.edit,
                    color: AppColors.brandPrimary,
                    size: 12.r,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    double subtotal = double.tryParse(widget.productDetails.price ?? "0") ?? 0;

    double totalAmount = (subtotal * _selectedQuantity) +
        (widget.productDetails.advanceAmount ?? 0);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
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
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyAppText(
              data: 'Order Summary',
              size: 13.sp,
              weight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Subtotal',
                  size: 12.sp,
                  color: AppColors.textSecondary,
                ),
                MyAppText(
                  data: '$_selectedQuantity × ₹ ${subtotal.toStringAsFixed(2)}',
                  size: 12.sp,
                  weight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 10.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Advance Payment',
                  size: 12.sp,
                  color: AppColors.textSecondary,
                ),
                MyAppText(
                  data:
                      '₹ ${(widget.productDetails.advanceAmount ?? 0).toStringAsFixed(2)}',
                  size: 12.sp,
                  weight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ✅ Delivery Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Delivery Fee',
                  size: 12.sp,
                  color: AppColors.textSecondary,
                ),
                MyAppText(
                  data: 'Free',
                  size: 12.sp,
                  weight: FontWeight.bold,
                  color: AppColors.brandPrimary,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Divider(color: AppColors.shimmerBaseDark.withOpacity(0.5)),
            SizedBox(height: 8.h),

            // ✅ Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Total Amount',
                  size: 14.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                MyAppText(
                  data: '₹ ${totalAmount.toStringAsFixed(2)}',
                  size: 14.sp,
                  weight: FontWeight.bold,
                  color: AppColors.brandPrimary,
                ),
              ],
            ),

            if ((widget.productDetails.advanceAmount ?? 0) > 0) ...[
              SizedBox(height: 10.h),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brandPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.brandPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MyAppText(
                        data:
                            'You will be charged an advance amount of ₹${(widget.productDetails.advanceAmount ?? 0).toStringAsFixed(2)} for your subscription to ${widget.productDetails.productName}.',
                        size: 10.sp,
                        color: AppColors.textPrimary,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final selectedSchedule = _selectedSchedule;
    final bool scheduleValid = selectedSchedule != null &&
        (!_requiresWeekdaySelection || _selectedWeekdays.isNotEmpty);
    final String weekdaysText = _requiresWeekdaySelection
        ? _weekdayOptions
            .where(
                (d) => d.value != null && _selectedWeekdays.contains(d.value))
            .map((d) => d.label ?? '')
            .where((label) => label.isNotEmpty)
            .join(', ')
        : '';
    final String deliveryScheduleText = selectedSchedule == null
        ? ''
        : (weekdaysText.isNotEmpty
            ? '${selectedSchedule.label ?? ''} ($weekdaysText)'
            : (selectedSchedule.label ?? ''));

    final slots = _deliverySlots;
    final DeliverySlot? deliveryTimeSlot =
        slots.isNotEmpty && _deliveryTimeIndex < slots.length
            ? slots[_deliveryTimeIndex]
            : null;
    final String deliveryTimeText =
        deliveryTimeSlot != null ? _slotDisplayText(deliveryTimeSlot) : '';
    final bool deliveryTimeValid = deliveryTimeSlot != null;

    final String deliveryText = [deliveryScheduleText, deliveryTimeText]
        .where((text) => text.isNotEmpty)
        .join(', ');

    double subtotal = double.tryParse(widget.productDetails.price ?? "0") ?? 0;
    double totalAmount = (subtotal * _selectedQuantity) +
        (widget.productDetails.advanceAmount ?? 0);

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
        child: context.read<StorageCubit>().isGuestMode != false
            ? MyAppButton(
                onPressed: () => context.push('/login', extra: {
                  'guestMode': true,
                }),
                label: 'Sign In to Proceed',
                icon: Iconsax.lock_outline,
              )
            : Builder(
                builder: (context) {
                  final storageState = context.watch<StorageCubit>().state;

                  GetAddressResponse? addressData;
                  try {
                    addressData = storageState.addressData
                        .firstWhere((item) => item.isPrimary == 1);
                  } catch (e) {
                    addressData = null;
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          MyAppIconButton(
                            icon: Iconsax.location_bold,
                            onPressed: () {},
                            variant: 'color',
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyAppText(
                                  data: addressData != null
                                      ? 'Delivery to ${addressData.label == 'Home' ? "Home" : addressData.label == 'Work' ? "Work" : "Other"}'
                                      : 'No Address Selected',
                                  size: 12.sp,
                                  weight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                if (addressData != null) ...[
                                  SizedBox(height: 4.h),
                                  MyAppText(
                                    data:
                                        '${addressData.address1 ?? ''} - ${addressData.address2 ?? ''}',
                                    size: 10.sp,
                                    color: AppColors.textSecondary,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () =>
                                context.push('/location-selection'),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: MyAppText(
                              data: addressData != null ? 'Change' : "Select",
                              size: 11.sp,
                              weight: FontWeight.w600,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (_selectedFrequency != null)
                        Row(
                          children: [
                            MyAppIconButton(
                              icon: Icons.access_time_rounded,
                              onPressed: () {},
                              variant: 'color',
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: MyAppText(
                                data:
                                    'Starting from ${DateFormat('MMM d, yyyy').format(_startDate)}, $deliveryText',
                                size: 11.sp,
                                maxLines: 4,
                                weight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 10.h),
                      MyAppButton(
                        isDisabled: !(_selectedFrequency != null &&
                            addressData != null &&
                            scheduleValid &&
                            deliveryTimeValid), // You can change this logic
                        onPressed: () =>
                            context.pushReplacement('/checkout', extra: {
                          "isSubscription": true,
                          "subscriptionDetails": CreateSubCheckoutRouteModel(
                            advanceAmount:
                                (widget.productDetails.advanceAmount ?? 0)
                                    .toString(),
                            imageUrl: widget.productDetails.image,
                            productId: int.parse(
                                widget.productDetails.productID.toString()),
                            productName:
                                widget.productDetails.productName ?? "",
                            quanity: _selectedQuantity,
                            startDate: _startDate,
                            price: subtotal.toString(),
                            subPrice: (_selectedQuantity * subtotal).toString(),
                            subProductId: int.parse(
                                widget.productDetails.productID.toString()),
                            subVariationID: int.parse(
                                widget.productDetails.productID.toString()),
                            weight: "500 ml",
                            deliverySlotId: deliveryTimeSlot?.id,
                            deliveryScheduleKey: selectedSchedule?.key,
                            deliveryDays: _requiresWeekdaySelection
                                ? _selectedWeekdays.toList()
                                : null,
                          ),
                          "deliveryNote":
                              'Starting from ${DateFormat('MMM d, yyyy').format(_startDate)}, $deliveryText',
                        }),
                        label: 'Continue • ₹ $totalAmount',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
