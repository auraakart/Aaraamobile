import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_state.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart' hide Image;
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_dialog.dart';
import 'package:aaraa_kart/presentation/common/my_app_icon_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/build_msg_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

enum DeliveryOptionType { instant, tomorrow, schedule }

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _deliveryTimeIndex = 0;

  DeliveryOptionType _selectedDeliveryOption = DeliveryOptionType.tomorrow;
  DateTime? _scheduledDate;

  DateTime get _tomorrowDeliveryDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  DateTime get _deliveryDate {
    final tomorrow = _tomorrowDeliveryDate;
    if (_selectedDeliveryOption == DeliveryOptionType.schedule &&
        _scheduledDate != null) {
      if (!_scheduledDate!.isBefore(tomorrow)) {
        return _scheduledDate!;
      }
    }
    return tomorrow;
  }

  String get _nextDeliveryLabel => 'Tomorrow';

  String get _deliveryDay {
    switch (_selectedDeliveryOption) {
      case DeliveryOptionType.instant:
        return 'Tomorrow';
      case DeliveryOptionType.tomorrow:
        return _nextDeliveryLabel;
      case DeliveryOptionType.schedule:
        if (_scheduledDate != null &&
            !_scheduledDate!.isBefore(_tomorrowDeliveryDate)) {
          return DateFormat('EEE, MMM d').format(_scheduledDate!);
        }
        return 'Schedule';
    }
  }

  List<DeliverySlot> _slots = [];

  @override
  void initState() {
    super.initState();
    _slots = _slotsFrom(context.read<ProductCubit>().state) ?? [];

    if (_slots.isEmpty) {
      context.read<ProductCubit>().getProducts("1", "20", null);
    }
  }

  List<DeliverySlot>? _slotsFrom(ProductState state) {
    if (state is ProductSuccess) return state.deliverySlots ?? const [];
    if (state is GetProductDetailsSuccess) {
      return state.deliverySlots ?? const [];
    }
    return null;
  }

  void _captureSlots(ProductState state) {
    final incoming = _slotsFrom(state);
    if (incoming == null) return;

    final unchanged = incoming.length == _slots.length &&
        List.generate(incoming.length, (i) => incoming[i].id == _slots[i].id)
            .every((same) => same);
    if (unchanged) return;

    setState(() {
      _slots = incoming;
      if (_deliveryTimeIndex >= _slots.length) _deliveryTimeIndex = 0;
    });
  }

  void _removeItem(id, [String? deliveryDate]) {
    context.read<CartCubit>().clearItem(id, deliveryDate: deliveryDate);
  }

  String _formatItemDeliveryDate(String? dateStr, [String? slot]) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  void _selectDeliveryTime(int index) {
    setState(() {
      _deliveryTimeIndex = index;
    });
  }

  List<DeliverySlot> get _deliverySlots => _slots;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        centerTitle: false,
        title: MyAppText(data: 'My Cart'),
      ),
      body: _buildCartContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  List<CartItem> get _orderableItems => context
      .read<CartCubit>()
      .state
      .items
      .where((item) => !item.isOutOfStock)
      .toList();

  double getTotalAmount() {
    double total = 0.0;

    for (var item in _orderableItems) {
      final price = double.tryParse(item.price.toString()) ?? 0.0;

      total += price * item.quantity;
    }

    return total;
  }

  Widget _buildEmptyCart() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: buildMsgState(
        context,
        'Your cart is empty',
        'Add some farm fresh items to your cart',
        () => context.pushReplacement('/bottom-bar'),
        'Browse Products',
        Iconsax.bag_2_bold,
      ),
    );
  }

  Widget _buildCartContent() {
    return BlocListener<ProductCubit, ProductState>(
      listener: (context, state) {
        _captureSlots(state);
        if (state is ProductSuccess) {
          context.read<CartCubit>().syncStockFromProducts(state.products);
        }
      },
      child: Column(
        children: [
          // BlocBuilder<CartCubit, CartState>(
          //   builder: (context, state) => _isLateOrder && state.items.isNotEmpty
          //       ? _buildLateOrderNotice()
          //       : const SizedBox.shrink(),
          // ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildCartItems(),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildLateOrderNotice() {
  //   return Container(
  //     width: double.infinity,
  //     margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
  //     padding: EdgeInsets.all(12.r),
  //     decoration: BoxDecoration(
  //       color: AppColors.warning.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(12.r),
  //       border: Border.all(color: AppColors.warning.withOpacity(0.3)),
  //     ),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(Iconsax.clock_bold, size: 16.r, color: AppColors.warning),
  //         SizedBox(width: 10.w),
  //         Expanded(
  //           child: MyAppText(
  //             data: 'Orders placed after 10 PM are delivered a day later than '
  //                 'usual. Yours will arrive on '
  //                 '${DateFormat('EEE, MMM d').format(_deliveryDate)}.',
  //             size: 10.sp,
  //             maxLines: 3,
  //             lineHeight: 1.4,
  //             weight: FontWeight.w500,
  //             color: AppColors.textPrimary,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCartItems() {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {},
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        List<CartItem> cartItems = state.items;
        final available =
            cartItems.where((item) => !item.isOutOfStock).toList();
        final outOfStock =
            cartItems.where((item) => item.isOutOfStock).toList();

        return cartItems.isEmpty
            ? _buildEmptyCart()
            : Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: available.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = available[index];
                      return GestureDetector(
                        onTap: () => {
                          // context.pushNamed(
                          //   'productDetails',
                          //   extra: {
                          //     'productID': item.id.toString(),
                          //     'productName': item.name,
                          //     'subProductDetails': subProductDetails,
                          //     "hasSubscribed":
                          //         context.read<StorageCubit>().isGuestMode ==
                          //                 false &&
                          //             hasSubscription &&
                          //             isSubscribed
                          //   },
                          // )
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 16.w, right: 16.w, top: 16.h),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80.w,
                                  height: 70.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPrimary
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.all(8.r),
                                  child: Image.network(
                                    item.imageUrl,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.local_drink_rounded,
                                        size: 32.r,
                                        color: AppColors.brandPrimary,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyAppText(
                                        data: item.name,
                                        size: 12.sp,
                                        weight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      SizedBox(height: 4.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.brandPrimary
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                          border: Border.all(
                                            color: AppColors.brandPrimary
                                                .withOpacity(0.2),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Iconsax.calendar_1_outline,
                                              size: 11.r,
                                              color: AppColors.brandPrimary,
                                            ),
                                            SizedBox(width: 4.w),
                                            Flexible(
                                              child: MyAppText(
                                                data: _formatItemDeliveryDate(
                                                    (item.deliveryDate !=
                                                                null &&
                                                            item.deliveryDate!
                                                                .isNotEmpty)
                                                        ? item.deliveryDate
                                                        : DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(
                                                                _deliveryDate),
                                                    item.deliverySlot),
                                                size: 9.5.sp,
                                                weight: FontWeight.w600,
                                                color: AppColors.brandPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyAppText(
                                            data: '₹${item.price}',
                                            size: 12.sp,
                                            weight: FontWeight.bold,
                                            color: AppColors.brandPrimary,
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () => context
                                                    .read<CartCubit>()
                                                    .removeItem(item.id,
                                                        deliveryDate:
                                                            item.deliveryDate),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                child: Container(
                                                  width: 22.w,
                                                  height: 22.h,
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .brandPrimary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.r),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 10.r,
                                                    color:
                                                        AppColors.brandPrimary,
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
                                                  data: '${item.quantity}',
                                                  size: 15.sp,
                                                  weight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.w,
                                              ),
                                              InkWell(
                                                onTap: () => context
                                                    .read<CartCubit>()
                                                    .addItem(
                                                        item.copyWith(
                                                            quantity: 1),
                                                        context),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  width: 22.w,
                                                  height: 22.h,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.brandPrimary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    showDialog(
                                      context: context,
                                      builder: (context) => MyAppDialog(
                                        title: "Delete Item?",
                                        subtitle:
                                            "Are you sure you want to remove this item?",
                                        positiveText: "Remove",
                                        negativeText: "Cancel",
                                        onPositivePressed: () {
                                          _removeItem(
                                              item.id, item.deliveryDate);
                                          context.pop();
                                        },
                                        onNegativePressed: () {
                                          context.pop();
                                        },
                                      ),
                                    )
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 10.r,
                                      color: Colors.red.shade400,
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
                  if (outOfStock.isNotEmpty)
                    _buildOutOfStockSection(outOfStock),
                  SizedBox(
                    height: 12.h,
                  ),
                  if (available.isNotEmpty) ...[
                    _buildDeliveryDate(),
                    if (_selectedDeliveryOption != DeliveryOptionType.instant)
                      _buildDeliveryTimeSelector(),
                    _buildOrderSummary(),
                  ],
                ],
              );
      },
    );
  }

  Widget _buildOutOfStockSection(List<CartItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
          child: Row(
            children: [
              Icon(
                Iconsax.bag_cross_1_outline,
                size: 15.r,
                color: AppColors.badgeError,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: MyAppText(
                  data: 'Unavailable (${items.length})',
                  size: 13.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
          child: MyAppText(
            data: 'These went out of stock and are not part of your order.',
            size: 10.sp,
            maxLines: 2,
            color: AppColors.textSecondary,
          ),
        ),
        ...items.map(_buildOutOfStockTile),
      ],
    );
  }

  Widget _buildOutOfStockTile(CartItem item) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDisabled),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.45,
              child: Container(
                width: 80.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(8.r),
                child: Image.network(
                  item.imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_drink_rounded,
                      size: 32.r,
                      color: AppColors.textDisabled,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppText(
                    data: item.name,
                    size: 12.sp,
                    weight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 4.h),
                  MyAppText(
                    data: _formatItemDeliveryDate(
                        (item.deliveryDate != null &&
                                item.deliveryDate!.isNotEmpty)
                            ? item.deliveryDate
                            : DateFormat('yyyy-MM-dd')
                                .format(_deliveryDate),
                        item.deliverySlot),
                    size: 9.5.sp,
                    weight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.badgeError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: MyAppText(
                      data: 'Out of Stock',
                      size: 9.sp,
                      weight: FontWeight.w700,
                      color: AppColors.badgeError,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  MyAppText(
                    data: '₹${item.price}  •  Qty ${item.quantity}',
                    size: 11.sp,
                    weight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => MyAppDialog(
                  title: "Delete Item?",
                  subtitle: "Are you sure you want to remove this item?",
                  positiveText: "Remove",
                  negativeText: "Cancel",
                  onPositivePressed: () {
                    _removeItem(item.id, item.deliveryDate);
                    context.pop();
                  },
                  onNegativePressed: () {
                    context.pop();
                  },
                ),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.close,
                  size: 10.r,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDate() {
    final cartItems = _orderableItems;
    final hasNormalItems = cartItems
        .any((i) => i.deliveryDate == null || i.deliveryDate!.isEmpty);
    final hasScheduledItems = cartItems
        .any((i) => i.deliveryDate != null && i.deliveryDate!.isNotEmpty);

    final bool isTomorrowSelected;
    final bool isScheduleSelected;

    if (hasNormalItems && hasScheduledItems) {
      isTomorrowSelected = true;
      isScheduleSelected = true;
    } else if (hasScheduledItems) {
      isTomorrowSelected = false;
      isScheduleSelected = true;
    } else {
      isTomorrowSelected =
          _selectedDeliveryOption != DeliveryOptionType.schedule;
      isScheduleSelected =
          _selectedDeliveryOption == DeliveryOptionType.schedule;
    }

    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.truck_fast_outline,
                color: AppColors.brandPrimary,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              MyAppText(
                data: 'Delivery',
                size: 12.sp,
                weight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildDeliveryOptionPill(
                title: 'Instant',
                isSelected: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Fast, Faster, Fastest – Instant Delivery Coming Soon! Earliest delivery is Tomorrow.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.brandPrimary,
                      margin: const EdgeInsets.all(10),
                    ),
                  );
                },
              ),
              _buildDeliveryOptionPill(
                title: 'Tomorrow',
                isSelected: isTomorrowSelected,
                onTap: () {
                  setState(() {
                    _selectedDeliveryOption = DeliveryOptionType.tomorrow;
                  });
                },
              ),
              _buildDeliveryOptionPill(
                title: 'Schedule',
                isSelected: isScheduleSelected,
                onTap: () async {
                  final pickedDate = await showDialog<DateTime>(
                    context: context,
                    builder: (context) => _SelectDeliveryDateDialog(
                      initialDate: (_scheduledDate != null &&
                              !_scheduledDate!.isBefore(_tomorrowDeliveryDate))
                          ? _scheduledDate!
                          : _tomorrowDeliveryDate,
                      firstSelectableDate: _tomorrowDeliveryDate,
                    ),
                  );
                  if (pickedDate != null &&
                      !pickedDate.isBefore(_tomorrowDeliveryDate)) {
                    setState(() {
                      _scheduledDate = pickedDate;
                      _selectedDeliveryOption = DeliveryOptionType.schedule;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptionPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandPrimary
                : AppColors.textTertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandPrimary
                  : AppColors.textTertiary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 12.r,
                ),
                SizedBox(width: 4.w),
              ],
              Flexible(
                child: MyAppText(
                  data: title,
                  size: 10.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  weight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeSelector() {
    final slots = _deliverySlots;

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
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.timer_1_outline,
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
                        data: 'No delivery time slots available',
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
                                : AppColors.textTertiary.withOpacity(0.3),
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

  Widget _buildOrderSummary() {
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
                  data: '₹ ${getTotalAmount().toString()}',
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
            Divider(
              color: AppColors.shimmerBaseDark.withOpacity(0.5),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Total',
                  size: 14.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyAppText(
                      data: '₹ ${getTotalAmount().toString()}',
                      size: 14.sp,
                      weight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final slots = _deliverySlots;
    final DeliverySlot? deliveryTimeSlot =
        slots.isNotEmpty && _deliveryTimeIndex < slots.length
            ? slots[_deliveryTimeIndex]
            : null;
    final String deliveryTimeText =
        deliveryTimeSlot != null ? _slotDisplayText(deliveryTimeSlot) : '';
    final bool deliveryTimeRequired =
        _selectedDeliveryOption != DeliveryOptionType.instant;
    final bool deliveryTimeValid =
        !deliveryTimeRequired || deliveryTimeSlot != null;

    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {},
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        List<CartItem> cartItems = state.items;
        final bool hasOrderableItems =
            cartItems.any((item) => !item.isOutOfStock);
        return cartItems.isEmpty
            ? SizedBox()
            : Container(
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
                          onPressed: () {
                            context.push('/login', extra: {
                              'guestMode': true,
                            });
                          },
                          label: 'Sign In to Proceed',
                          icon: Iconsax.lock_outline,
                        )
                      : BlocConsumer<StorageCubit, StorageState>(
                          listener: (context, state) {},
                          buildWhen: (previous, current) => previous != current,
                          builder: (context, state) {
                            GetAddressResponse? addressData;
                            try {
                              addressData = state.addressData
                                  .where((item) => item.isPrimary == 1)
                                  .first;
                            } catch (e) {}

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
                                    if (addressData != null)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyAppText(
                                              data:
                                                  'Delivery to ${addressData.label == 'Home' ? "Home" : addressData.label == 'Work' ? "Work" : "Other"}',
                                              size: 12.sp,
                                              weight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            SizedBox(height: 4.h),
                                            MyAppText(
                                              data:
                                                  '${addressData.address1.toString()} - ${addressData.address2.toString()}',
                                              size: 10.sp,
                                              color: AppColors.textSecondary,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyAppText(
                                              data: 'No Address Selected',
                                              size: 10.sp,
                                              weight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                            ),
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
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: MyAppText(
                                        data: addressData != null
                                            ? 'Change'
                                            : "Select",
                                        size: 11.sp,
                                        weight: FontWeight.w600,
                                        color: AppColors.brandPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     MyAppIconButton(
                                       icon: Iconsax.clock_bold,
                                       onPressed: () {},
                                       variant: 'color',
                                     ),
                                     SizedBox(width: 12.w),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment:
                                             CrossAxisAlignment.start,
                                         children: [
                                           if (cartItems.any((i) =>
                                                   !i.isOutOfStock &&
                                                   (i.deliveryDate == null ||
                                                       i.deliveryDate!.isEmpty)) ||
                                               !cartItems.any((i) =>
                                                   !i.isOutOfStock &&
                                                   i.deliveryDate != null &&
                                                   i.deliveryDate!.isNotEmpty)) ...[
                                             MyAppText(
                                               data: deliveryTimeText.isNotEmpty
                                                   ? '$_deliveryDay, $deliveryTimeText'
                                                   : _deliveryDay,
                                               size: 12.sp,
                                               weight: FontWeight.w500,
                                               color: AppColors.textPrimary,
                                             ),
                                             ...cartItems
                                                 .where((i) =>
                                                     !i.isOutOfStock &&
                                                     (i.deliveryDate == null ||
                                                         i.deliveryDate!.isEmpty))
                                                 .map(
                                                   (item) => Padding(
                                                     padding: EdgeInsets.only(
                                                         top: 2.h),
                                                     child: MyAppText(
                                                       data: item.name,
                                                       size: 10.sp,
                                                       color: AppColors
                                                           .textSecondary,
                                                     ),
                                                   ),
                                                 ),
                                           ],
                                           if (cartItems.any((i) =>
                                               !i.isOutOfStock &&
                                               i.deliveryDate != null &&
                                               i.deliveryDate!.isNotEmpty)) ...[
                                             if (cartItems.any((i) =>
                                                 !i.isOutOfStock &&
                                                 (i.deliveryDate == null ||
                                                     i.deliveryDate!.isEmpty)))
                                               SizedBox(height: 8.h),
                                             MyAppText(
                                               data: 'Scheduled:',
                                               size: 11.sp,
                                               weight: FontWeight.bold,
                                               color: AppColors.textPrimary,
                                             ),
                                             SizedBox(height: 3.h),
                                             ...cartItems
                                                 .where((i) =>
                                                     !i.isOutOfStock &&
                                                     i.deliveryDate != null &&
                                                     i.deliveryDate!.isNotEmpty)
                                                 .map(
                                                   (item) => Padding(
                                                     padding: EdgeInsets.only(
                                                         top: 2.h),
                                                     child: MyAppText(
                                                       data:
                                                           '${item.name} — ${_formatItemDeliveryDate(item.deliveryDate, item.deliverySlot)}',
                                                       size: 10.sp,
                                                       color: AppColors
                                                           .textSecondary,
                                                     ),
                                                   ),
                                                 ),
                                           ],
                                         ],
                                       ),
                                     ),
                                   ],
                                 ),
                                SizedBox(height: 20.h),
                                if (!hasOrderableItems) ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Iconsax.bag_cross_1_outline,
                                        size: 14.r,
                                        color: AppColors.badgeError,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: MyAppText(
                                          data:
                                              'Everything in your cart is out of stock. Remove these items or add something available to continue.',
                                          size: 10.sp,
                                          maxLines: 3,
                                          lineHeight: 1.4,
                                          color: AppColors.badgeError,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                                MyAppButton(
                                  isDisabled: addressData == null ||
                                      !deliveryTimeValid ||
                                      !hasOrderableItems,
                                  onPressed: () {
                                    final validDeliveryDate =
                                        _deliveryDate.isBefore(_tomorrowDeliveryDate)
                                            ? _tomorrowDeliveryDate
                                            : _deliveryDate;
                                    final scheduledItems = _orderableItems
                                        .where((i) =>
                                            i.deliveryDate != null &&
                                            i.deliveryDate!.isNotEmpty)
                                        .toList();
                                    String note;
                                    if (scheduledItems.isNotEmpty &&
                                        scheduledItems.length ==
                                            _orderableItems.length) {
                                      note = scheduledItems
                                          .map((i) =>
                                              '${i.name}: ${_formatItemDeliveryDate(i.deliveryDate, i.deliverySlot)}')
                                          .join('\n');
                                    } else if (scheduledItems.isNotEmpty) {
                                      final scheduledSummary = scheduledItems
                                          .map((i) =>
                                              'Scheduled - ${i.name}: ${_formatItemDeliveryDate(i.deliveryDate, i.deliverySlot)}')
                                          .join('\n');
                                      note =
                                          'Standard: ${DateFormat('MMM d, yyyy').format(validDeliveryDate)}${deliveryTimeText.isNotEmpty ? ', $deliveryTimeText' : ''}\n$scheduledSummary';
                                    } else {
                                      note =
                                          '${DateFormat('MMM d, yyyy').format(validDeliveryDate)}${deliveryTimeText.isNotEmpty ? ', $deliveryTimeText' : ''}';
                                    }

                                    context.push('/checkout', extra: {
                                      "isSubscription": false,
                                      "deliveryNote": note,
                                    });
                                  },
                                  label:
                                      'Proceed to Checkout • ₹ ${getTotalAmount().toString()}',
                                  icon: Iconsax.shopping_bag_outline,
                                ),
                              ],
                            );
                          },
                        ),
                ),
              );
      },
    );
  }
}

class _SelectDeliveryDateDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstSelectableDate;

  const _SelectDeliveryDateDialog({
    required this.initialDate,
    required this.firstSelectableDate,
  });

  @override
  State<_SelectDeliveryDateDialog> createState() =>
      _SelectDeliveryDateDialogState();
}

class _SelectDeliveryDateDialogState extends State<_SelectDeliveryDateDialog> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  late DateTime _firstSelectableDate;

  static const List<String> _weekdays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    _firstSelectableDate = DateTime(
      widget.firstSelectableDate.year,
      widget.firstSelectableDate.month,
      widget.firstSelectableDate.day,
    );
    if (_firstSelectableDate.isBefore(tomorrow)) {
      _firstSelectableDate = tomorrow;
    }

    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    if (_selectedDate.isBefore(_firstSelectableDate)) {
      _selectedDate = _firstSelectableDate;
    }

    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _canGoBack {
    final earliestMonth =
        DateTime(_firstSelectableDate.year, _firstSelectableDate.month);
    return _visibleMonth.isAfter(earliestMonth);
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int firstWeekdayOffset =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday % 7;
    final int daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final int prevMonthDays =
        DateTime(_visibleMonth.year, _visibleMonth.month, 0).day;
    final int totalCells = ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyAppText(
              data: 'Select Delivery Date',
              size: 16.sp,
              weight: FontWeight.w700,
              color: AppColors.textPrimary,
              align: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _canGoBack ? () => _changeMonth(-1) : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(6.r),
                    child: Icon(
                      Icons.chevron_left,
                      size: 22.sp,
                      color: _canGoBack
                          ? AppColors.textPrimary
                          : const Color(0xFFC7C7CC),
                    ),
                  ),
                ),
                MyAppText(
                  data: DateFormat('MMMM yyyy').format(_visibleMonth),
                  size: 14.sp,
                  weight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                InkWell(
                  onTap: () => _changeMonth(1),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(6.r),
                    child: Icon(
                      Icons.chevron_right,
                      size: 22.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Weekdays header
            Row(
              children: _weekdays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: MyAppText(
                          data: day,
                          size: 11.5.sp,
                          weight: FontWeight.w500,
                          color: const Color(0xFF3C3C43),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 8.h),
            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                if (index < firstWeekdayOffset) {
                  final dayNumber =
                      prevMonthDays - firstWeekdayOffset + index + 1;
                  return Center(
                    child: MyAppText(
                      data: '$dayNumber',
                      size: 12.5.sp,
                      weight: FontWeight.w400,
                      color: const Color(0xFFC7C7CC),
                    ),
                  );
                }

                if (index < firstWeekdayOffset + daysInMonth) {
                  final dayNumber = index - firstWeekdayOffset + 1;
                  final day = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month,
                    dayNumber,
                  );
                  final isSelectable = !day.isBefore(_firstSelectableDate);
                  final isSelected = _isSameDay(day, _selectedDate);

                  return Center(
                    child: InkWell(
                      onTap: isSelectable
                          ? () {
                              setState(() {
                                _selectedDate = day;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E1E1E)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: MyAppText(
                          data: '$dayNumber',
                          size: 13.sp,
                          weight: isSelected
                              ? FontWeight.w700
                              : (isSelectable
                                  ? FontWeight.w500
                                  : FontWeight.w400),
                          color: isSelected
                              ? Colors.white
                              : (isSelectable
                                  ? const Color(0xFF1C1C1E)
                                  : const Color(0xFFB0B0B5)),
                        ),
                      ),
                    ),
                  );
                }

                final dayNumber =
                    index - (firstWeekdayOffset + daysInMonth) + 1;
                return Center(
                  child: MyAppText(
                    data: '$dayNumber',
                    size: 13.sp,
                    weight: FontWeight.w400,
                    color: const Color(0xFFB0B0B5),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            // Cancel and Confirm buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      alignment: Alignment.center,
                      child: MyAppText(
                        data: 'Cancel',
                        size: 14.sp,
                        weight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final confirmedDate =
                          _selectedDate.isBefore(_firstSelectableDate)
                              ? _firstSelectableDate
                              : _selectedDate;
                      Navigator.of(context).pop(confirmedDate);
                    },
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      alignment: Alignment.center,
                      child: MyAppText(
                        data: 'Confirm',
                        size: 14.sp,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
