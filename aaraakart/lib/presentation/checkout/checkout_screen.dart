import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_state.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_state.dart';
import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/create_sub_checkout_route_model.dart';
import 'package:aaraa_kart/data/model/create_subscription_request.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/order_create_request.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_icon_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/payment/payment_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final bool isSubscription;
  final String deliveryNote;
  final CreateSubCheckoutRouteModel? subscriptionDetails;
  const CheckoutScreen(
      {super.key,
      required this.isSubscription,
      required this.deliveryNote,
      this.subscriptionDetails});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0;

  PaymentGateway? _selectedGateway = defaultPaymentGateway;

  String get _gatewayId =>
      _selectedGateway?.gatewayId ?? defaultPaymentGateway?.gatewayId ?? 'paytm';

  GetAddressResponse? customerAddress;
  OrderCreateRequest? orderRequestDetails;
  CreateSubscriptionRequestModel? subRequestDetails;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'Pay Online',
      'subtitle': 'UPI, Cards, Net Banking',
      'icon': Iconsax.wallet_2_bold,
      'status': true
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = 0;
  }

  void _selectPaymentMethod(int index) {
    setState(() {
      _selectedPaymentMethod = index;
    });
  }

  List<CartItem> get _orderableItems => context
      .read<CartCubit>()
      .state
      .items
      .where((item) => !item.isOutOfStock)
      .toList();

  String _formatDeliveryDate(String? dateStr, [String? slot]) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _getDeliveryScheduleText() {
    if (widget.isSubscription) {
      return widget.deliveryNote;
    }

    final scheduledItems = _orderableItems
        .where((i) => i.deliveryDate != null && i.deliveryDate!.isNotEmpty)
        .toList();

    if (scheduledItems.isEmpty) {
      return widget.deliveryNote;
    }

    String standardPart = '';
    if (widget.deliveryNote.isNotEmpty) {
      final firstLine = widget.deliveryNote.split('\n').first;
      if (firstLine.startsWith('Standard:')) {
        standardPart = firstLine;
      } else if (!firstLine.startsWith('Scheduled -')) {
        standardPart = 'Standard: $firstLine';
      }
    }

    final scheduledLines = scheduledItems
        .map((i) =>
            'Scheduled - ${i.name}: ${_formatDeliveryDate(i.deliveryDate, i.deliverySlot)}')
        .toList();

    if (standardPart.isNotEmpty) {
      return '$standardPart\n${scheduledLines.join('\n')}';
    } else {
      return scheduledLines.join('\n');
    }
  }

  double getTotalAmount() {
    double total = 0.0;

    for (var item in _orderableItems) {
      final price = double.tryParse(item.price.toString()) ?? 0.0;

      total += price * item.quantity;
    }

    return total;
  }

  void _placeSubscription() async {
    final createRequest = CreateSubscriptionRequestModel(
        billing: SubBilling(
            address1: customerAddress!.address1 ?? '',
            address2: customerAddress!.address2!.isNotEmpty
                ? '${customerAddress!.address2} (Land Mark - ${customerAddress!.landmark})'
                : customerAddress!.address2 ?? '',
            customerNote: widget.deliveryNote,
            landmark: customerAddress!.landmark,
            city: customerAddress!.city,
            country: customerAddress!.country,
            email: context.read<StorageCubit>().userData!.email,
            firstName: customerAddress!.name,
            lastName: "",
            phone: context.read<StorageCubit>().userData!.phoneNumber,
            postcode: customerAddress!.postcode,
            state: customerAddress!.state),
        customerId: int.parse(
            context.read<StorageCubit>().userData!.customerID.toString()),
        billingInterval: 1,
        billingPeriod: "day",
        deliverySlot: widget.subscriptionDetails?.deliverySlotId,
        deliverySchedule: widget.subscriptionDetails?.deliveryScheduleKey,
        deliveryDays: widget.subscriptionDetails?.deliveryDays,
        nextPaymentDate: null,
        paymentMethod: _gatewayId,
        paymentMethodTitle: "Online Payment",
        productIds: [widget.subscriptionDetails!.subVariationID ?? 0],
        startDate: widget.subscriptionDetails!.startDate,
        status: "active");
    setState(() {
      subRequestDetails = createRequest;
    });

    BlocProvider.of<SubscriptionsCubit>(context)
        .createSubscription(createRequest);
  }

  void _placeOrder(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Every item in your cart is out of stock. Please update your cart to continue.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.error,
          margin: const EdgeInsets.all(10),
        ),
      );
      return;
    }

    List<LineItem>? lineItem = [];

    for (int i = 0; i < cartItems.length; i++) {
      lineItem.add(LineItem(
        productId: int.parse(cartItems[i].id),
        quantity: cartItems[i].quantity,
        variationId: "0",
      ));
    }

    final List<Map<String, dynamic>> metaData = [];
    final scheduledItems = cartItems
        .where((item) =>
            item.deliveryDate != null && item.deliveryDate!.isNotEmpty)
        .toList();
    if (scheduledItems.isNotEmpty) {
      final datesSummary = scheduledItems
          .map((e) =>
              '${e.name}: ${e.deliveryDate}${e.deliverySlot != null && e.deliverySlot!.isNotEmpty ? " (${e.deliverySlot})" : ""}')
          .join(', ');
      metaData.add({
        "key": "_scheduled_delivery_dates",
        "value": datesSummary,
      });
      metaData.add({
        "key": "delivery_date",
        "value": scheduledItems.first.deliveryDate,
      });
      if (scheduledItems.first.deliverySlot != null &&
          scheduledItems.first.deliverySlot!.isNotEmpty) {
        metaData.add({
          "key": "delivery_slot",
          "value": scheduledItems.first.deliverySlot,
        });
      }
    }

    final createRequest = OrderCreateRequest(
        billing: Billing(
            address1: customerAddress!.address1 ?? '',
            address2: customerAddress!.address2!.isNotEmpty
                ? '${customerAddress!.address2} (Land Mark - ${customerAddress!.landmark})'
                : customerAddress!.address2 ?? '',
            customerNote: _getDeliveryScheduleText(),
            landmark: customerAddress!.landmark,
            city: customerAddress!.city,
            country: customerAddress!.country,
            email: context.read<StorageCubit>().userData!.email,
            firstName: customerAddress!.name,
            lastName: "",
            phone: context.read<StorageCubit>().userData!.phoneNumber,
            postcode: customerAddress!.postcode,
            state: customerAddress!.state),
        lineItems: lineItem,
        metaData: metaData.isNotEmpty ? metaData : null,
        customerID: int.parse(
            context.read<StorageCubit>().userData!.customerID.toString()),
        paymentMethod: _gatewayId,
        paymentMethodTitle: "Online Payment",
        setPaid: false);
    setState(() {
      orderRequestDetails = createRequest;
    });
    BlocProvider.of<OrderCubit>(context).createOrder(createRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        centerTitle: false,
        title: MyAppText(data: 'Checkout'),
      ),
      body: _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _buildDeliveryAddress(),
        SizedBox(height: 16.h),
        _buildDeliveryTime(),
        SizedBox(height: 16.h),
        _buildPaymentMethods(),
        SizedBox(height: 16.h),
        if (!widget.isSubscription)
          _buildOrderItems()
        else
          _buildSubOrderItem(),
        // SizedBox(height: 16.h),
        // _buildApplyCoupon(),
        SizedBox(height: 16.h),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return BlocConsumer<StorageCubit, StorageState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        customerAddress =
            state.addressData.where((item) => item.isPrimary == 1).first;
        return Container(
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
                    MyAppIconButton(
                      icon: Iconsax.location_bold,
                      onPressed: () {},
                      variant: "color",
                    ),
                    SizedBox(width: 12.w),
                    MyAppText(
                      data: 'Delivery Address',
                      size: 13.sp,
                      weight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/location-selection'),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: MyAppText(
                        data: 'Change',
                        size: 9.sp,
                        weight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppIconButton(
                      icon: Iconsax.truck_fast_bold,
                      onPressed: () {},
                      variant: "color",
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MyAppText(
                                data: customerAddress!.label == 'Home'
                                    ? "Home"
                                    : customerAddress!.label == 'Work'
                                        ? "Work"
                                        : "Other",
                                size: 13.sp,
                                weight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.brandPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: MyAppText(
                                  data: 'Default',
                                  size: 9.sp,
                                  weight: FontWeight.w500,
                                  color: AppColors.brandPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          MyAppText(
                            data:
                                '${customerAddress!.address1} - ${customerAddress!.address2.toString()}',
                            size: 10.sp,
                            color: AppColors.textSecondary,
                            lineHeight: 1.4,
                            maxLines: 3,
                          ),
                          SizedBox(height: 8.h),
                          MyAppText(
                            data: customerAddress!.mobileNumber ?? '',
                            size: 10.sp,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeliveryTime() {
    return Container(
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
                MyAppIconButton(
                  icon: Iconsax.clock_bold,
                  onPressed: () {},
                  variant: "color",
                ),
                SizedBox(width: 12.w),
                MyAppText(
                  data: 'Delivery Schedule',
                  size: 13.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const Spacer(),
                if (widget.isSubscription)
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: MyAppText(
                      data: 'Change',
                      size: 9.sp,
                      weight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
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
                    Iconsax.calendar_2_bold,
                    color: AppColors.brandPrimary,
                    size: 18.r,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        return MyAppText(
                          data: _getDeliveryScheduleText(),
                          size: 10.sp,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
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
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Iconsax.money_tick_bold,
                    color: AppColors.brandPrimary,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12.w),
                MyAppText(
                  data: 'Payment Method',
                  size: 13.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentMethods.length,
              separatorBuilder: (context, index) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final bool isSelected = _selectedPaymentMethod == index;

                return InkWell(
                  onTap: () => _selectPaymentMethod(index),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brandPrimary.withOpacity(0.2)
                                : AppColors.brandPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.brandPrimary
                                  : AppColors.brandPrimary.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            method['icon'],
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.textSecondary.withOpacity(0.5),
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyAppText(
                                data: method['title'],
                                size: 12.sp,
                                weight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.brandPrimary
                                    : AppColors.textPrimary,
                              ),
                              SizedBox(height: 4.h),
                              MyAppText(
                                data: method['subtitle'],
                                size: 10.sp,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        Radio(
                          value: index,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) =>
                              _selectPaymentMethod(value as int),
                          activeColor: AppColors.brandPrimary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // if (_selectedPaymentMethod == 0)
            //   PaymentGatewaySelector(
            //     selected: _selectedGateway,
            //     onChanged: (gateway) =>
            //         setState(() => _selectedGateway = gateway),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubOrderItem() {
    return Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Subscription Item',
                  size: 13.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(6.r),
                  child: Image.network(
                    widget.subscriptionDetails!.imageUrl.toString(),
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.local_drink_rounded,
                        size: 20.r,
                        color: AppColors.brandPrimary,
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyAppText(
                        data: widget.subscriptionDetails!.productName!,
                        maxLines: 1,
                        size: 12.sp,
                        weight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                MyAppText(
                  data:
                      '${widget.subscriptionDetails!.quanity} × ₹${widget.subscriptionDetails!.price}',
                  size: 11.sp,
                  weight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {},
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        List<CartItem> cartItems =
            state.items.where((item) => !item.isOutOfStock).toList();
        final int excludedCount = state.items.length - cartItems.length;

        return Container(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyAppText(
                      data: 'Order Items',
                      size: 13.sp,
                      weight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: MyAppText(
                        data: 'Edit Cart',
                        size: 10.5.sp,
                        weight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (excludedCount > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.badgeError.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: AppColors.badgeError.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Iconsax.bag_cross_1_outline,
                          size: 14.r,
                          color: AppColors.badgeError,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: MyAppText(
                            data: excludedCount == 1
                                ? '1 item went out of stock and has been left out of this order. It stays in your cart.'
                                : '$excludedCount items went out of stock and have been left out of this order. They stay in your cart.',
                            size: 10.sp,
                            maxLines: 3,
                            lineHeight: 1.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 18.h,
                    color: AppColors.shimmerBaseDark.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Row(
                      children: [
                        Container(
                          width: 45.w,
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(6.r),
                          child: Image.network(
                            item.imageUrl,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_drink_rounded,
                                size: 20.r,
                                color: AppColors.brandPrimary,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyAppText(
                                data: item.name,
                                maxLines: 2,
                                size: 11.sp,
                                weight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              if (item.deliveryDate != null &&
                                  item.deliveryDate!.isNotEmpty) ...[
                                SizedBox(height: 3.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPrimary
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: MyAppText(
                                    data: _formatDeliveryDate(
                                        item.deliveryDate, item.deliverySlot),
                                    size: 9.sp,
                                    weight: FontWeight.w600,
                                    color: AppColors.brandPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        MyAppText(
                          data: '${item.quantity} × ₹${item.price}',
                          size: 11.sp,
                          weight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary() {
    return Container(
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
              data: 'Price Details',
              size: 13.sp,
              weight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Subtotal',
                  size: 12.sp,
                  color: AppColors.textSecondary,
                ),
                MyAppText(
                  data: widget.isSubscription
                      ? '₹${widget.subscriptionDetails!.subPrice.toString()}'
                      : '₹${getTotalAmount().toString()}',
                  size: 12.sp,
                  weight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            if (widget.isSubscription) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyAppText(
                    data: 'Advance Amount',
                    size: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  MyAppText(
                    data:
                        '₹${widget.subscriptionDetails!.advanceAmount.toString()}',
                    size: 12.sp,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ],
              )
            ],
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppText(
                  data: 'Delivery Fee',
                  size: 12.sp,
                  color: AppColors.textSecondary,
                ),
                MyAppText(
                  data: 'FREE',
                  size: 12.sp,
                  weight: FontWeight.w600,
                  color: AppColors.badgeSuccess,
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
                  data: 'Total Amount',
                  size: 13.sp,
                  weight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyAppText(
                      data: !widget.isSubscription
                          ? '₹${getTotalAmount().toString()}'
                          : '₹${double.parse(widget.subscriptionDetails!.subPrice.toString()) + double.parse(widget.subscriptionDetails!.advanceAmount.toString())}',
                      size: 13.sp,
                      weight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ],
                ),
              ],
            ),
            if (widget.isSubscription) ...[
              const SizedBox(height: 16),
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
                            'You will be charged an advance amount of ₹${widget.subscriptionDetails!.advanceAmount} for your subscription to ${widget.subscriptionDetails!.productName}.',
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
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BlocConsumer<SubscriptionsCubit, SubscriptionState>(
      listener: (context, state) {
        if (state is CreateSubscriptionSuccess) {
          final subscriptionAmount =
              double.parse(widget.subscriptionDetails!.subPrice.toString()) +
                  double.parse(
                      widget.subscriptionDetails!.advanceAmount.toString());

          startOnlinePayment(
            context,
            gateway: _selectedGateway,
            subRequestDetails: subRequestDetails,
            isSubscription: true,
            isWallet: false,
            subOrderID: state.subResponse.orderId.toString(),
            subResponseDetails: state.subResponse,
            subScriptionAmount: subscriptionAmount,
          );
        } else if (state is CreateSubscriptionError) {
          context.go("/order-failed", extra: {"errorMessage": state.message});
        }
      },
      builder: (context, state) {
        return BlocConsumer<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderCreateSuccess) {
              startOnlinePayment(
                context,
                gateway: _selectedGateway,
                orderRequestDetails: orderRequestDetails,
                orderResponseDetails: state.orderResponse,
                isSubscription: false,
                isWallet: false,
              );
            } else if (state is OrderCreateError) {
              context
                  .go("/order-failed", extra: {"errorMessage": state.message});
            }
          },
          buildWhen: (previous, current) => previous != current,
          builder: (context, cartState) {
            List<CartItem> cartItems = _orderableItems;
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
                child: MyAppButton(
                  loading: cartState is OrderCreateLoading ||
                      state is CreateSubscriptionLoading,
                  onPressed: () => {
                    widget.isSubscription
                        ? _placeSubscription()
                        : _placeOrder(cartItems)
                  },
                  label:
                      '${widget.isSubscription ? 'Create Subscription' : 'Place Order'} • ₹${!widget.isSubscription ? getTotalAmount().toString() : '${double.parse(widget.subscriptionDetails!.subPrice.toString()) + double.parse(widget.subscriptionDetails!.advanceAmount.toString())}'}',
                  icon: Iconsax.tick_circle_outline,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
