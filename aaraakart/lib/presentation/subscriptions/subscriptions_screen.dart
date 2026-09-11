import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_state.dart';
import 'package:aaraa_kart/data/model/get_customer_subs.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_dialog.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/history/order_note.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscription_schedule_calendar_sheet.dart';
import 'package:aaraa_kart/presentation/widgets/build_cart_icon.dart';
import 'package:aaraa_kart/presentation/widgets/build_msg_widget.dart';
import 'package:aaraa_kart/presentation/widgets/whatsapp_launcher.dart';
import 'package:aaraa_kart/data/model/scheduled_delivery_item.dart';
import 'package:aaraa_kart/data/model/get_customer_order.dart' hide LineItem;
import 'package:aaraa_kart/core/di/injection.dart';
import 'package:aaraa_kart/domain/order_repository.dart';
import 'package:aaraa_kart/presentation/subscriptions/daily_scheduled_orders_card.dart';
import 'package:aaraa_kart/presentation/subscriptions/schedule_future_delivery_sheet.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscription_calendar_ribbon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class _PauseDisplayInfo {
  final String title;
  final String? subtitle;

  const _PauseDisplayInfo({required this.title, this.subtitle});
}

class SubscriptionScreen extends StatefulWidget {
  final Product? productDetails;

  const SubscriptionScreen({
    super.key,
    this.productDetails,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<GetCustomerSubscriptionsResponseModel>? subscriptionsData = [];
  bool loading = true;
  String? updatingSubscriptionId;

  late DateTime _selectedCalendarDate;
  List<ScheduledDeliveryItem> _futureOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final now = DateTime.now();
    _selectedCalendarDate = DateTime(now.year, now.month, now.day);

    if (context.read<StorageCubit>().isGuestMode == false) {
      final subState = context.read<SubscriptionsCubit>().state;
      if (subState is SubscriptionSuccess) {
        subscriptionsData = subState.subscriptions;
        loading = false;
      } else if (subState is SubscriptionError) {
        loading = false;
      }

      // Always trigger fresh getSubscriptions to prevent stale subscription state
      context.read<SubscriptionsCubit>().getSubscriptions(
          context.read<StorageCubit>().userData!.customerID);
      _fetchCustomerOrders();
    } else {
      loading = false;
    }
  }

  Future<void> _fetchCustomerOrders() async {
    final customerId = context.read<StorageCubit>().userData?.customerID;
    if (customerId == null || customerId.isEmpty) return;

    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 35));
      final to = now.add(const Duration(days: 90));

      int page = 1;
      const int maxPages = 5;
      final List<HistoryProduct> allOrders = [];

      while (page <= maxPages) {
        final res = await getIt<OrderRepository>()
            .getFutureCustomerOrderList(customerId, page, from, to);
        if (res.products != null && res.products!.isNotEmpty) {
          allOrders.addAll(res.products!);
          final totalPages = res.totalPages ?? 1;
          if (page >= totalPages || res.products!.length < 50) {
            break;
          }
          page++;
        } else {
          break;
        }
      }

      final List<ScheduledDeliveryItem> fetchedOrders = [];

      if (allOrders.isNotEmpty) {
        for (final order in allOrders) {
          final rawStatus = order.status?.toLowerCase().trim() ?? '';
          final status =
              rawStatus.startsWith('wc-') ? rawStatus.substring(3) : rawStatus;

          // Delivery Calendar shows orders only when status is: processing, completed, or delivered.
          // Explicitly exclude pending or any other non-confirmed status.
          const allowedStatuses = {'processing', 'completed', 'delivered'};
          if (!allowedStatuses.contains(status)) {
            continue;
          }

          // Exclude subscription orders and renewal orders from future one-time orders
          if (_isSubscriptionOrder(order)) {
            continue;
          }

          DateTime? explicitDeliveryDate;
          DateTime? explicitOrderDate;
          String? slot;
          bool isInstant = false;

          final customerNote = order.customerNote?.toLowerCase() ?? '';
          if (customerNote.contains('instant')) {
            isInstant = true;
          }

          if (order.metaData != null) {
            for (final m in order.metaData!) {
              final k = m.key?.toLowerCase() ?? '';
              final v = m.value?.toString().toLowerCase() ?? '';
              if (k.contains('delivery_date') ||
                  k.contains('delivery-date') ||
                  k == '_delivery_date' ||
                  k == 'jckwds_date') {
                explicitDeliveryDate = _parseDate(m.value);
              }
              if (k.contains('order_date') ||
                  k == '_order_date' ||
                  k == 'scheduled_order_date') {
                explicitOrderDate = _parseDate(m.value);
              }
              if (k.contains('slot') ||
                  k.contains('delivery_slot') ||
                  k == '_delivery_slot' ||
                  k == 'jckwds_timeslot') {
                slot = m.value?.toString();
                if (slot != null && slot.toLowerCase().contains('instant')) {
                  isInstant = true;
                }
              }
              if (k.contains('delivery_type') ||
                  k.contains('order_type') ||
                  k == '_delivery_type' ||
                  k == '_order_type') {
                if (v.contains('instant')) {
                  isInstant = true;
                }
              }
            }
          }

          if (order.shippingLines != null) {
            for (final s in order.shippingLines!) {
              if (s.toString().toLowerCase().contains('instant')) {
                isInstant = true;
              }
            }
          }

          final rawOrderDate = _parseDate(order.dateCreated) ?? DateTime.now();
          final orderDate = explicitOrderDate ?? rawOrderDate;
          final DateTime orderDeliveryDate;

          if (isInstant) {
            orderDeliveryDate = rawOrderDate;
            slot = 'Instant';
          } else if (explicitDeliveryDate != null) {
            orderDeliveryDate = explicitDeliveryDate;
          } else {
            // Tomorrow or Schedule one-time order: Delivery Date = Order Date + 1 day
            orderDeliveryDate = orderDate.add(const Duration(days: 1));
          }

          if (order.lineItems != null) {
            for (final li in order.lineItems!) {
              final price = double.tryParse(li.price?.toString() ?? '') ??
                  double.tryParse(li.total?.toString() ?? '') ??
                  0.0;
              final qty = int.tryParse(li.quantity?.toString() ?? '1') ?? 1;

              fetchedOrders.add(
                ScheduledDeliveryItem(
                  id: 'ORD_${order.id}_${li.id ?? 0}',
                  productName: li.name ?? 'One-Time Order',
                  productImage: li.image?.src,
                  quantity: qty,
                  price: price,
                  deliverySlot: slot ?? 'Morning (6:00 AM - 8:00 AM)',
                  status:
                      isInstant ? 'Instant' : (order.status ?? 'Processing'),
                  isOneTime: true,
                  deliveryDate: orderDeliveryDate,
                  orderDate: orderDate,
                ),
              );
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _futureOrders = fetchedOrders;
        });
      }
    } catch (e) {
      debugPrint('Error fetching customer orders for future calendar: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyAppText(
          data: message,
          color: AppColors.white,
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  void _showSubscriptionSchedule(
    BuildContext context,
    GetCustomerSubscriptionsResponseModel product,
  ) {
    SubscriptionScheduleCalendarSheet.show(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        showLeading: false,
        title: MyAppText(
          data: 'My Subscriptions',
          weight: FontWeight.w700,
          size: 18.sp,
        ),
        actions: [
          BlocConsumer<SubscriptionsCubit, SubscriptionState>(
            listener: (context, state) {},
            buildWhen: (previous, current) {
              return previous != current;
            },
            builder: (context, state) {
              return state is SubscriptionLoading ||
                      state is SubscriptionUpdateLoading
                  ? SizedBox()
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: IconButton(
                        constraints: BoxConstraints(
                          minWidth: 40.w,
                          minHeight: 40.h,
                        ),
                        padding: EdgeInsets.all(8.h),
                        icon: Icon(
                          Iconsax.clock_outline,
                          color: AppColors.brandPrimaryDark,
                          size: 20.r,
                        ),
                        onPressed: () => context.push('/sub-history'),
                      ),
                    );
            },
          ),
          CartIconButton(),
        ],
      ),
      body: context.read<StorageCubit>().isGuestMode == false
          ? RefreshIndicator(
              onRefresh: () async {
                context.read<SubscriptionsCubit>().getSubscriptions(
                    context.read<StorageCubit>().userData!.customerID);
                await _fetchCustomerOrders();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.brandPrimary,
              child: BlocConsumer<SubscriptionsCubit, SubscriptionState>(
                buildWhen: (previous, current) {
                  // Don't rebuild during update loading to prevent UI flicker
                  if (current is SubscriptionUpdateLoading) return false;
                  return previous != current;
                },
                listener: (context, state) {
                  if (state is SubscriptionLoading) {
                    setState(() {
                      loading = true;
                    });
                  } else if (state is SubscriptionSuccess) {
                    setState(() {
                      loading = false;
                      subscriptionsData = state.subscriptions;
                    });
                  } else if (state is SubscriptionError) {
                    setState(() {
                      loading = false;
                    });
                    _showToast('Failed to load subscriptions', isError: true);
                  }

                  if (state is SubscriptionUpdateLoading) {
                  } else if (state is SubscriptionUpdateSuccess) {
                    setState(() {
                      updatingSubscriptionId = null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: MyAppText(
                          data: 'Subscription updated successfully!',
                          color: AppColors.white,
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );

                    context.read<SubscriptionsCubit>().getSubscriptions(
                        context.read<StorageCubit>().userData!.customerID);
                  } else if (state is SubscriptionUpdateError) {
                    setState(() {
                      updatingSubscriptionId = null;
                    });
                    final msg =
                        state.message.replaceAll('Exception: ', '').trim();
                    _showToast(
                        msg.isNotEmpty ? msg : 'Failed to update subscription',
                        isError: true);
                    context.read<SubscriptionsCubit>().getSubscriptions(
                        context.read<StorageCubit>().userData!.customerID);
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: loading || state is SubscriptionLoading
                        ? SizedBox(
                            height: 400.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brandPrimary,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              if (subscriptionsData != null &&
                                  subscriptionsData!.isNotEmpty) ...[
                                _buildSubscriptionSummary(),
                                _buildActiveSubscriptionsTab(),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 10.h),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.borderDefault,
                                  ),
                                ),
                              ],
                              SubscriptionCalendarRibbon(
                                selectedDate: _selectedCalendarDate,
                                onDateSelected: (day) {
                                  setState(() {
                                    _selectedCalendarDate = day;
                                  });
                                },
                                subscriptions: subscriptionsData,
                                futureDeliveries: _futureOrders,
                              ),
                              DailyScheduledOrdersCard(
                                selectedDate: _selectedCalendarDate,
                                deliveries: _getScheduledDeliveriesForDate(
                                    _selectedCalendarDate),
                                onScheduleFutureDelivery:
                                    _openScheduleFutureDeliverySheet,
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ),
                  );
                },
              ),
            )
          : buildMsgState(
              context,
              'You are not signed in',
              'Continue signing in to view subscriptions',
              () => context.push('/login', extra: {
                    'guestMode': true,
                  }),
              'Sign In',
              Iconsax.lock_outline),
    );
  }

  Widget _buildSubscriptionSummary() {
    final activeCount =
        (subscriptionsData ?? []).where((p) => p.status == "active").length;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            bottom: -20,
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(50.r),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.card_bold,
                    color: Colors.white70,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  MyAppText(
                    data: 'Your Subscriptions',
                    color: Colors.white70,
                    size: 12.sp,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyAppText(
                    data: '$activeCount',
                    color: Colors.white,
                    size: 26.sp,
                    weight: FontWeight.w800,
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: MyAppText(
                      data: activeCount == 1
                          ? 'Active Subscription'
                          : 'Active Subscriptions',
                      color: Colors.white,
                      size: 13.5.sp,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionsTab() {
    final activeSubscriptions = (subscriptionsData ?? [])
        .where((p) =>
            p.status == "active" ||
            p.status == "on-hold" ||
            p.status == "pause")
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Column(
        children: [
          if (activeSubscriptions.isEmpty) ...[
            SizedBox(
              height: 100.h,
            ),
            buildMsgState(
                context,
                'No Active subscriptions yet',
                'Your subscription will appear here once you have an active subscription',
                () => context.pushReplacement('/bottom-bar'),
                'Browse Products',
                Iconsax.card_bold)
          ] else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeSubscriptions.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final product = activeSubscriptions[index];
                return _buildSubscriptionCard(product);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(GetCustomerSubscriptionsResponseModel product) {
    final lineItem =
        product.lineItems?.isNotEmpty == true ? product.lineItems!.first : null;
    final pauseDisplayInfo = _getPauseDisplayInfo(product);

    return InkWell(
      onTap: () => _showSubscriptionDetails(context, product),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.borderDefault.withValues(alpha: 0.7),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: lineItem?.image?.src != null
                        ? MyAppCachedImage(
                            imageUrl: lineItem!.image!.src.toString(),
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Iconsax.box_outline,
                            size: 20.sp,
                            color: AppColors.brandPrimary,
                          ),
                  ),
                  Positioned(
                    right: -3.w,
                    bottom: -3.w,
                    child: Container(
                      width: 18.r,
                      height: 18.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 10.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppText(
                      data: lineItem?.name?.toString() ?? 'Subscription',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      weight: FontWeight.w700,
                      size: 13.5.sp,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 3.h),
                    MyAppText(
                      data: 'Qty ${lineItem?.quantity ?? 1} · #${product.id}',
                      size: 10.5.sp,
                      weight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              MyAppText(
                data: '₹${lineItem?.price?.toString() ?? product.total}',
                weight: FontWeight.w700,
                size: 15.sp,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildMetaRow(
            icon: Iconsax.truck_outline,
            label: 'Delivery slot',
            value:
                product.deliverySlot?.label ?? product.deliverySlot?.timeLabel,
            placeholder: 'Not selected',
          ),
          _buildMetaRow(
            icon: Iconsax.calendar_outline,
            label: 'Delivery days',
            value: _getDeliveryScheduleDisplay(product),
            placeholder: 'Not selected',
          ),
          if (pauseDisplayInfo != null) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.borderDefault,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.calendar_1_outline,
                        size: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: MyAppText(
                          data: pauseDisplayInfo.title,
                          size: 12.sp,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (pauseDisplayInfo.subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Padding(
                      padding: EdgeInsets.only(left: 24.w),
                      child: MyAppText(
                        data: pauseDisplayInfo.subtitle!,
                        size: 11.sp,
                        weight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            children: [
              // Notes button
              Expanded(
                child: InkWell(
                  onTap: () => _showSubscriptionNotes(context, product),
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    height: 32.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.message_text_outline,
                          size: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 5.w),
                        MyAppText(
                          data: 'Notes',
                          size: 11.5.sp,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Schedule button
              Expanded(
                child: InkWell(
                  onTap: () => _showSubscriptionSchedule(context, product),
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    height: 32.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.calendar_edit_outline,
                          size: 14.sp,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 5.w),
                        MyAppText(
                          data: 'Schedule',
                          size: 11.5.sp,
                          weight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Settings button
              InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => MyAppDialog(
                    title: "Modify or Cancel Subscription?",
                    subtitle:
                        "Connect with our support team to modify or cancel your subscription.",
                    positiveText: "Yes",
                    negativeText: "No",
                    onPositivePressed: () {
                      handleWhatsAppLauncher(
                        BrandConfig.instance.content.whatsappNumber,
                        'Hi, I need help on this Subscription #${product.id}',
                        context,
                      );
                    },
                    onNegativePressed: () {
                      context.pop();
                    },
                  ),
                ),
                borderRadius: BorderRadius.circular(18.r),
                child: SizedBox(
                  width: 40.w,
                  height: 32.h,
                  child: Icon(
                    Iconsax.setting_2_outline,
                    size: 19.sp,
                    color: AppColors.textSecondary,
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

  bool _isSubscriptionOrder(HistoryProduct order) {
    final type = order.orderType?.trim().toLowerCase();
    if (type == 'parent' || type == 'renewal') return true;
    if (type == 'one_time' || type == 'onetime' || type == 'one-time') {
      return false;
    }

    // 1. Check parentId (WooCommerce renewal/child orders link to parent subscription)
    if (order.parentId != null && order.parentId != 0) {
      return true;
    }

    // 2. Check createdVia
    final createdVia = order.createdVia?.toLowerCase() ?? '';
    if (createdVia.contains('subscription') ||
        createdVia.contains('wcs') ||
        createdVia == 'wcs_renewal_order') {
      return true;
    }

    // 3. Check customerNote
    final customerNote = order.customerNote?.toLowerCase() ?? '';
    if (customerNote.contains('subscription') ||
        customerNote.contains('recurring')) {
      return true;
    }

    // 4. Check known subscription IDs in subscriptionsData
    if (subscriptionsData != null && subscriptionsData!.isNotEmpty) {
      final orderIdStr = order.id?.toString();
      final parentIdStr = order.parentId?.toString();
      final isKnownSub = subscriptionsData!.any((sub) =>
          sub.id?.toString() == orderIdStr ||
          (parentIdStr != null && sub.id?.toString() == parentIdStr));
      if (isKnownSub) return true;
    }

    // 5. Check order metadata
    if (order.metaData != null) {
      for (final m in order.metaData!) {
        final k = m.key?.toLowerCase() ?? '';
        final v = m.value?.toString().toLowerCase() ?? '';

        if (k.contains('subscription') ||
            k.contains('wcs_') ||
            k == '_subscription_renewal' ||
            k == '_subscription_initial_payment' ||
            k == '_subscription_resubscribe' ||
            k == '_subscription_switch' ||
            k == '_subscription_id' ||
            k == 'subscription_id' ||
            k == 'wcs_renewal_order') {
          return true;
        }

        if ((k == 'order_type' ||
                k == '_order_type' ||
                k == 'delivery_type' ||
                k == '_delivery_type') &&
            (v.contains('subscription') || v.contains('recurring'))) {
          return true;
        }

        if (k == 'is_subscription' && (v == 'true' || v == '1' || v == 'yes')) {
          return true;
        }
      }
    }

    // 6. Check line items metadata
    if (order.lineItems != null) {
      for (final li in order.lineItems!) {
        if (li.metaData != null) {
          for (final lm in li.metaData!) {
            final lk = lm.key?.toLowerCase() ?? '';
            final lv = lm.value?.toString().toLowerCase() ?? '';
            if (lk.contains('subscription') ||
                lk.contains('wcs_') ||
                (lk == 'is_subscription' &&
                    (lv == 'true' || lv == '1' || lv == 'yes'))) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSubScheduledOnDate(
      GetCustomerSubscriptionsResponseModel sub, DateTime day) {
    final scheduleType = sub.deliverySchedule?.type?.toLowerCase() ?? 'daily';
    final normalized = DateTime(day.year, day.month, day.day);

    final startDate =
        _parseDate(sub.startDateGmt ?? sub.dateCreated) ?? DateTime(2020, 1, 1);

    // [DEBUG LOG - INVESTIGATION ONLY]
    // ignore: avoid_print
    print('[DEBUG CALENDAR] _isSubScheduledOnDate -> Sub ID: ${sub.id}, Target Day: ${DateFormat('yyyy-MM-dd').format(day)}, StartDate: ${DateFormat('yyyy-MM-dd').format(startDate)}, deliverySchedule.type: ${sub.deliverySchedule?.type}, billingPeriod: ${sub.billingPeriod}, billingInterval: ${sub.billingInterval}, calculated scheduleType: $scheduleType');

    if (normalized.isBefore(startDate)) return false;

    switch (scheduleType) {
      case 'daily':
        return true;
      case 'alternate':
        final diffDays = normalized.difference(startDate).inDays;
        // ignore: avoid_print
        print('[DEBUG CALENDAR ALTERNATE] Sub ID: ${sub.id}, diffDays: $diffDays, diffDays % 2 == 0: ${diffDays % 2 == 0}');
        return diffDays % 2 == 0;
      case 'weekend':
        return day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday;
      case 'custom':
        final days = sub.deliverySchedule?.days;
        if (days != null && days.isNotEmpty) {
          final isoWeekday = day.weekday;
          final scheduleWeekday = isoWeekday == 7 ? 0 : isoWeekday;
          return days.contains(scheduleWeekday);
        }
        final dayNames = sub.deliverySchedule?.dayNames;
        if (dayNames != null && dayNames.isNotEmpty) {
          final weekdayName = DateFormat('EEEE').format(day).toLowerCase();
          final shortWeekdayName = DateFormat('E').format(day).toLowerCase();
          return dayNames.any((name) {
            final n = name.trim().toLowerCase();
            return n == weekdayName || n == shortWeekdayName;
          });
        }
        return true;
      default:
        return true;
    }
  }

  bool _isSubPausedOnDate(
      GetCustomerSubscriptionsResponseModel sub, DateTime day) {
    final status = sub.status?.toLowerCase() ?? '';
    final rawPauseDates = sub.pauseDates ?? [];
    final rawResume = sub.resumeDate;

    final isPausedFlag = status == 'pause' ||
        sub.isPaused == true ||
        (status == 'on-hold' &&
            (sub.needsPayment != true ||
                sub.pauseType != null ||
                rawPauseDates.isNotEmpty));

    final isPermanent = sub.pauseType == 'permanent' ||
        (isPausedFlag && rawPauseDates.isEmpty && rawResume == null);

    final normalized = DateTime(day.year, day.month, day.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (isPermanent) {
      if (!normalized.isBefore(tomorrow)) {
        return true;
      }
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(normalized);

    for (final item in rawPauseDates) {
      if (item is Map) {
        final start = _parseDate(item['start'] ??
            item['from'] ??
            item['pause_start_date'] ??
            item['start_date']);
        final end = _parseDate(item['end'] ??
            item['to'] ??
            item['pause_end_date'] ??
            item['end_date']);
        if (start != null && end != null) {
          if (!normalized.isBefore(start) && !normalized.isAfter(end)) {
            return true;
          }
        }
      } else if (item != null) {
        final d = _parseDate(item);
        if (d != null && _isSameCalendarDay(d, normalized)) {
          return true;
        }
        if (item.toString().contains(dateStr)) {
          return true;
        }
      }
    }

    return false;
  }


  String? _getDeliveryScheduleDisplay(
      GetCustomerSubscriptionsResponseModel product) {
    final scheduleType =
        product.deliverySchedule?.type?.toLowerCase().trim() ?? '';
    final label = product.deliverySchedule?.label?.trim() ?? '';

    final isCustom = scheduleType == 'custom' ||
        label.toLowerCase().contains('custom');

    if (isCustom) {
      final dayNames = product.deliverySchedule?.dayNames;
      if (dayNames != null && dayNames.isNotEmpty) {
        return dayNames.join(', ');
      }

      final days = product.deliverySchedule?.days;
      if (days != null && days.isNotEmpty) {
        const Map<int, String> weekdayNames = {
          0: 'Sunday',
          1: 'Monday',
          2: 'Tuesday',
          3: 'Wednesday',
          4: 'Thursday',
          5: 'Friday',
          6: 'Saturday',
          7: 'Sunday',
        };
        final names = days
            .map((d) => weekdayNames[d])
            .whereType<String>()
            .toList();
        if (names.isNotEmpty) {
          return names.join(', ');
        }
      }
    }

    return product.deliverySchedule?.label;
  }

  List<ScheduledDeliveryItem> _getScheduledDeliveriesForDate(DateTime day) {
    final List<ScheduledDeliveryItem> items = [];
    final normalized = DateTime(day.year, day.month, day.day);

    // 1. Active subscription deliveries
    if (subscriptionsData != null && subscriptionsData!.isNotEmpty) {
      for (final sub in subscriptionsData!) {
        final status = sub.status?.toLowerCase() ?? '';
        if (status != 'active' && status != 'on-hold') continue;

        if (_isSubScheduledOnDate(sub, normalized) &&
            !_isSubPausedOnDate(sub, normalized)) {
          final lineItems = sub.lineItems ?? [];
          final slotName =
              sub.deliverySlot?.label ?? sub.deliverySlot?.timeLabel;

          if (lineItems.isNotEmpty) {
            for (final li in lineItems) {
              final price = double.tryParse(li.price?.toString() ?? '') ??
                  double.tryParse(sub.total?.toString() ?? '') ??
                  0.0;
              final qty = int.tryParse(li.quantity?.toString() ?? '1') ?? 1;

              items.add(
                ScheduledDeliveryItem(
                  id: 'SUB_${sub.id}_${li.id ?? 0}',
                  subscriptionId: sub.id?.toString(),
                  productName: li.name?.toString() ?? 'Subscription Delivery',
                  productImage: li.image?.src?.toString(),
                  quantity: qty,
                  price: price,
                  deliverySlot: slotName,
                  status: 'Scheduled',
                  isOneTime: false,
                  deliveryDate: normalized,
                ),
              );
            }
          } else {
            items.add(
              ScheduledDeliveryItem(
                id: 'SUB_${sub.id}',
                subscriptionId: sub.id?.toString(),
                productName: 'Subscription #${sub.id}',
                quantity: 1,
                price: double.tryParse(sub.total?.toString() ?? '') ?? 0.0,
                deliverySlot: slotName,
                status: 'Scheduled',
                isOneTime: false,
                deliveryDate: normalized,
              ),
            );
          }
        }
      }
    }

    // 2. Future scheduled orders from backend API
    final matchingFuture = _futureOrders.where(
      (d) => _isSameCalendarDay(d.deliveryDate, normalized),
    );
    items.addAll(matchingFuture);

    return items;
  }

  void _openScheduleFutureDeliverySheet() {
    ScheduleFutureDeliverySheet.show(
      context,
      initialDate: _selectedCalendarDate,
      onFutureDeliveryCreated: () async {
        await _fetchCustomerOrders();
      },
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  _PauseDisplayInfo? _getPauseDisplayInfo(
      GetCustomerSubscriptionsResponseModel product) {
    final status = product.status?.toLowerCase() ?? '';
    final rawPauseDates = product.pauseDates ?? [];
    final rawResume = product.resumeDate;

    final isPausedFlag = status == 'pause' ||
        product.isPaused == true ||
        (status == 'on-hold' &&
            (product.needsPayment != true ||
                product.pauseType != null ||
                rawPauseDates.isNotEmpty));

    final isPermanent = product.pauseType == 'permanent' ||
        (isPausedFlag && rawPauseDates.isEmpty && rawResume == null);

    final dateFormat = DateFormat('MMM d, yyyy');

    // Case 3: Long Pause ("Pause Until I Resume")
    if (isPermanent) {
      DateTime pauseStart = DateTime.now().add(const Duration(days: 1));
      final parsedCreated = _parseDate(product.dateModifiedGmt ??
          product.dateModified ??
          product.dateCreatedGmt ??
          product.dateCreated);
      if (parsedCreated != null) {
        pauseStart = parsedCreated.add(const Duration(days: 1));
      }
      final formattedStart = dateFormat.format(pauseStart);
      return _PauseDisplayInfo(
        title: 'Paused from $formattedStart (Until manual resume)',
      );
    }

    // Parse all paused dates
    final List<DateTime> sortedDates = [];
    DateTime? rangeStart;
    DateTime? rangeEnd;

    for (final item in rawPauseDates) {
      if (item is Map) {
        final s = _parseDate(item['start'] ??
            item['from'] ??
            item['pause_start_date'] ??
            item['start_date']);
        final e = _parseDate(item['end'] ??
            item['to'] ??
            item['pause_end_date'] ??
            item['end_date']);
        if (s != null && e != null) {
          rangeStart = s;
          rangeEnd = e;
        } else if (s != null) {
          sortedDates.add(s);
        }
      } else if (item != null) {
        final d = _parseDate(item);
        if (d != null) {
          sortedDates.add(d);
        }
      }
    }

    sortedDates.sort();

    // Check if sortedDates represent a continuous date range
    if (rangeStart == null && sortedDates.isNotEmpty) {
      if (sortedDates.length >= 2) {
        bool isContinuous = true;
        for (int i = 0; i < sortedDates.length - 1; i++) {
          if (sortedDates[i + 1].difference(sortedDates[i]).inDays > 1) {
            isContinuous = false;
            break;
          }
        }
        if (isContinuous) {
          rangeStart = sortedDates.first;
          rangeEnd = sortedDates.last;
        }
      }
    }

    final parsedResume = _parseDate(rawResume);

    // Case 2: Date Range
    if (rangeStart != null && rangeEnd != null) {
      final startStr = dateFormat.format(rangeStart);
      final endStr = dateFormat.format(rangeEnd);
      final resumeDate = parsedResume ?? rangeEnd.add(const Duration(days: 1));
      final resumeStr = dateFormat.format(resumeDate);

      return _PauseDisplayInfo(
        title: 'Paused from $startStr to $endStr',
        subtitle: 'Resumes from $resumeStr',
      );
    }

    // Case 1: Specific dates
    if (sortedDates.isNotEmpty) {
      final formattedDates =
          sortedDates.map((d) => dateFormat.format(d)).toList();
      final String datesStr;
      if (formattedDates.length <= 3) {
        datesStr = formattedDates.join(' & ');
      } else {
        datesStr =
            '${formattedDates.take(3).join(' & ')} +${formattedDates.length - 3} more';
      }

      final resumeStr =
          parsedResume != null ? dateFormat.format(parsedResume) : null;

      return _PauseDisplayInfo(
        title: 'Paused on $datesStr',
        subtitle: resumeStr != null ? 'Resumes from $resumeStr' : null,
      );
    }

    // Fallback if marked paused
    if (isPausedFlag) {
      final resumeStr =
          parsedResume != null ? dateFormat.format(parsedResume) : null;
      final pauseStart =
          _parseDate(product.dateModified ?? product.dateCreated) ??
              DateTime.now();
      final startStr = dateFormat.format(pauseStart);

      if (resumeStr != null) {
        return _PauseDisplayInfo(
          title: 'Paused from $startStr',
          subtitle: 'Resumes from $resumeStr',
        );
      }
      return _PauseDisplayInfo(
        title: 'Paused from $startStr (Until manual resume)',
      );
    }

    return null;
  }

  String _formatSelectedDates(List<DateTime> dates) {
    const maxShown = 3;
    final formatted = dates
        .take(maxShown)
        .map((d) => DateFormat('MMM d').format(d))
        .join(', ');
    if (dates.length > maxShown) {
      return '$formatted +${dates.length - maxShown} more';
    }
    return formatted;
  }

  Widget _buildPillButton({
    required String label,
    required bool filled,
    VoidCallback? onTap,
    IconData? icon,
    Color? color,
    bool isLoading = false,
  }) {
    final baseColor = color ?? AppColors.brandPrimary;
    final disabled = onTap == null && !isLoading;
    final backgroundColor = filled
        ? (disabled ? baseColor.withValues(alpha: 0.3) : baseColor)
        : AppColors.backgroundBase;
    final foregroundColor = filled
        ? Colors.white
        : (disabled ? baseColor.withValues(alpha: 0.4) : baseColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: isLoading
              ? [
                  SizedBox(
                    width: 13.r,
                    height: 13.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  ),
                ]
              : [
                  if (icon != null) ...[
                    Icon(icon, size: 13.sp, color: foregroundColor),
                    SizedBox(width: 5.w),
                  ],
                  MyAppText(
                    data: label,
                    weight: FontWeight.w600,
                    size: 10.sp,
                    color: foregroundColor,
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    String? value,
    String placeholder = 'Not selected',
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 13.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          MyAppText(
            data: label,
            size: 11.sp,
            weight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: MyAppText(
              data: hasValue ? value : placeholder,
              size: 11.sp,
              weight: hasValue ? FontWeight.w500 : FontWeight.w400,
              fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
              color: hasValue ? AppColors.textPrimary : AppColors.textDisabled,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionNotes(
      BuildContext context, GetCustomerSubscriptionsResponseModel subProduct) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OrderNotesBottomSheet.subscription(
        subscriptionId: subProduct.id.toString(),
      ),
    );
  }

  void _showSubscriptionDetails(
      BuildContext context, GetCustomerSubscriptionsResponseModel subProduct) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<SubscriptionsCubit>(),
        child: BlocBuilder<SubscriptionsCubit, SubscriptionState>(
          builder: (context, state) {
            GetCustomerSubscriptionsResponseModel currentSub = subProduct;
            if (state is SubscriptionSuccess) {
              currentSub = state.subscriptions.firstWhere(
                (s) => s.id == subProduct.id,
                orElse: () => subProduct,
              );
            } else if (subscriptionsData != null) {
              currentSub = subscriptionsData!.firstWhere(
                (s) => s.id == subProduct.id,
                orElse: () => subProduct,
              );
            }

            // [DEBUG LOG - Subscription Details Modal]
            // ignore: avoid_print
            print('=== [DEBUG UI] Subscription Details Modal ===');
            // ignore: avoid_print
            print('Modal Sub ID: ${currentSub.id}');
            // ignore: avoid_print
            print('Modal Status: ${currentSub.status}');
            // ignore: avoid_print
            print('Modal nextPaymentDateGmt raw: ${currentSub.nextPaymentDateGmt}');
            final renewalValue = _formatDateValue(currentSub.nextPaymentDateGmt);
            // ignore: avoid_print
            print('Modal Final Next Renewal UI Value: $renewalValue');

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.88,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              builder: (context, scrollController) =>
                  _buildDetailsSheet(context, currentSub, scrollController),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsSheet(
    BuildContext context,
    GetCustomerSubscriptionsResponseModel sub,
    ScrollController scrollController,
  ) {
    final status = sub.status ?? '';
    final pauseInfo = _extractPauseInfo(sub.pauseDates);
    final isPausedFlag = status == 'pause' ||
        sub.isPaused == true ||
        (status == 'on-hold' &&
            (sub.needsPayment != true ||
                sub.pauseType != null ||
                pauseInfo.hasSelectedDates));

    final isPermanentPause = sub.pauseType == 'permanent' ||
        (isPausedFlag &&
            !pauseInfo.hasSelectedDates &&
            sub.resumeDate == null);

    final isPaused = isPausedFlag;
    final isOnHold = status == 'on-hold' && !isPaused;

    final Color statusColor;
    final IconData statusIcon;
    final String statusLabel;

    if (isPaused) {
      statusColor = AppColors.warning;
      statusIcon = Iconsax.pause_circle_bold;
      statusLabel = 'Paused';
    } else if (isOnHold) {
      statusColor = AppColors.error;
      statusIcon = Iconsax.warning_2_bold;
      statusLabel = 'On Hold';
    } else {
      statusColor = AppColors.success;
      statusIcon = Iconsax.tick_circle_bold;
      statusLabel = 'Active';
    }

    final parsedResume = _tryParseDate(sub.resumeDate);
    final resumeDate = isPermanentPause
        ? null
        : (parsedResume ??
            (pauseInfo.hasSelectedDates
                ? pauseInfo.selectedDates.last.add(const Duration(days: 1))
                : null));

    final hasScheduledPause = !isPaused &&
        !isPermanentPause &&
        (pauseInfo.hasSelectedDates || resumeDate != null);

    final lineItems = sub.lineItems ?? [];
    final heroItem = lineItems.isNotEmpty ? lineItems.first : null;

    final itemsTotal = lineItems.fold<double>(0, (sum, item) {
      final lineTotal = double.tryParse(item.total?.toString() ?? '');
      if (lineTotal != null) return sum + lineTotal;
      final price = (item.price ?? 0).toDouble();
      final qty = double.tryParse(item.quantity?.toString() ?? '') ?? 1;
      return sum + price * qty;
    });
    final shippingTotal = _toAmount(sub.shippingTotal);
    final discountTotal = _toAmount(sub.discountTotal);
    final grandTotal = _toAmount(sub.total);

    final address = _formatAddress(sub);
    final recipient = [sub.billing?.firstName, sub.billing?.lastName]
        .map((e) => e?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join(' ');
    final phone = sub.billing?.phone?.trim() ?? '';

    final finalRenewalUIValue = _formatDateValue(sub.nextPaymentDateGmt);
    // [DEBUG LOG - final Next renewal UI value]
    // ignore: avoid_print
    print('=== [DEBUG UI] _buildDetailsSheet Next renewal Row ===');
    // ignore: avoid_print
    print('Sub ID: ${sub.id}, Raw: ${sub.nextPaymentDateGmt}, Formatted UI: $finalRenewalUIValue');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildSheetHeader(context, sub, statusColor, statusIcon, statusLabel),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHeroCard(sub, heroItem, grandTotal),
                  if (isPaused) ...[
                    SizedBox(height: 12.h),
                    _buildSheetNotice(
                      color: statusColor,
                      icon: Iconsax.pause_circle_bold,
                      title: isPermanentPause
                          ? 'Paused until manually resumed'
                          : (pauseInfo.isRange
                              ? 'Paused from ${DateFormat('MMM d').format(pauseInfo.rangeStart!)} - ${DateFormat('MMM d, yyyy').format(pauseInfo.rangeEnd!)}'
                              : (pauseInfo.hasSelectedDates
                                  ? 'Paused for ${pauseInfo.selectedDates.length} days'
                                  : 'Deliveries are paused')),
                      subtitle: (resumeDate != null && !isPermanentPause)
                          ? 'Resumes on ${DateFormat('MMM d, yyyy').format(resumeDate)}'
                          : null,
                    ),
                  ],
                  if (hasScheduledPause) ...[
                    SizedBox(height: 12.h),
                    _buildSheetNotice(
                      color: AppColors.warning,
                      icon: Iconsax.calendar_1_outline,
                      title: pauseInfo.isRange
                          ? 'Pause scheduled from ${DateFormat('MMM d, yyyy').format(pauseInfo.rangeStart!)}'
                          : (pauseInfo.hasSelectedDates
                              ? 'Pause scheduled from ${DateFormat('MMM d, yyyy').format(pauseInfo.selectedDates.first)}'
                              : 'Pause scheduled'),
                      subtitle: resumeDate != null
                          ? 'Resumes from ${DateFormat('MMM d, yyyy').format(resumeDate)}'
                          : null,
                    ),
                  ],
                  if (isOnHold) ...[
                    SizedBox(height: 12.h),
                    _buildSheetNotice(
                      color: statusColor,
                      icon: Iconsax.wallet_remove_outline,
                      title: sub.needsPayment == true
                          ? 'Payment pending'
                          : 'Payment not received',
                      subtitle:
                          'Complete the payment to resume your deliveries.',
                    ),
                  ],
                  SizedBox(height: 20.h),
                  _buildSheetSectionTitle(
                      'Schedule & Billing', Iconsax.calendar_1_outline),
                  SizedBox(height: 10.h),
                  _buildSheetCard(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Column(
                      children: [
                        _buildSheetDetailRow(
                          icon: Iconsax.calendar_1_outline,
                          label: 'Delivery days',
                          value: _getDeliveryScheduleDisplay(sub) ??
                              (sub.deliverySchedule?.dayNames?.isNotEmpty ==
                                      true
                                  ? sub.deliverySchedule!.dayNames!.join(', ')
                                  : null),
                        ),
                        _buildSheetDetailRow(
                          icon: Iconsax.clock_outline,
                          label: 'Time slot',
                          value: sub.deliverySlot?.label ??
                              sub.deliverySlot?.timeLabel,
                        ),
                        if (_billingCycleLabel(sub) != null)
                          _buildSheetDetailRow(
                            icon: Iconsax.repeat_outline,
                            label: 'Billing cycle',
                            value: _billingCycleLabel(sub),
                          ),
                        _buildSheetDetailRow(
                          icon: Iconsax.tag_outline,
                          label: 'Started on',
                          value: _formatDateValue(
                              sub.startDateGmt ?? sub.dateCreated),
                        ),
                        _buildSheetDetailRow(
                          icon: Iconsax.calendar_tick_outline,
                          label: 'Next renewal',
                          value: _formatDateValue(sub.nextPaymentDateGmt),
                          isLast: true,
                        ),
                        SizedBox(height: 12.h),
                        Divider(height: 1, color: AppColors.borderDisabled),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPillButton(
                                icon: Iconsax.calendar_1_outline,
                                label: 'Edit Schedule',
                                filled: false,
                                onTap: () {
                                  Navigator.pop(context);
                                  _showSubscriptionSchedule(context, sub);
                                },
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildPillButton(
                                icon: Iconsax.message_2_outline,
                                label: 'Notes',
                                filled: false,
                                onTap: () {
                                  Navigator.pop(context);
                                  _showSubscriptionNotes(context, sub);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSheetSectionTitle(
                    'Items',
                    Iconsax.box_outline,
                    trailing:
                        '${lineItems.length} ${lineItems.length == 1 ? 'item' : 'items'}',
                  ),
                  SizedBox(height: 10.h),
                  _buildSheetCard(
                    padding: EdgeInsets.all(14.r),
                    child: lineItems.isEmpty
                        ? MyAppText(
                            data: 'No items in this subscription',
                            size: 11.sp,
                            color: AppColors.textTertiary,
                          )
                        : Column(
                            children: [
                              for (int i = 0; i < lineItems.length; i++) ...[
                                if (i > 0) ...[
                                  SizedBox(height: 12.h),
                                  Divider(
                                      height: 1,
                                      color: AppColors.borderDisabled),
                                  SizedBox(height: 12.h),
                                ],
                                _buildSheetLineItem(lineItems[i]),
                              ],
                            ],
                          ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSheetSectionTitle(
                      'Delivery Address', Iconsax.location_outline),
                  SizedBox(height: 10.h),
                  _buildSheetCard(
                    padding: EdgeInsets.all(14.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Iconsax.location_outline,
                            size: 16.sp,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (recipient.isNotEmpty) ...[
                                MyAppText(
                                  data: recipient,
                                  size: 11.5.sp,
                                  weight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(height: 4.h),
                              ],
                              MyAppText(
                                data: address ?? 'Address not available',
                                size: 10.5.sp,
                                weight: FontWeight.w500,
                                lineHeight: 1.5,
                                maxLines: 5,
                                color: address != null
                                    ? AppColors.textSecondary
                                    : AppColors.textDisabled,
                                fontStyle: address != null
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                              if (phone.isNotEmpty) ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Iconsax.call_outline,
                                        size: 11.sp,
                                        color: AppColors.textTertiary),
                                    SizedBox(width: 6.w),
                                    MyAppText(
                                      data: phone,
                                      size: 10.5.sp,
                                      weight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSheetSectionTitle(
                      'Payment Summary', Iconsax.receipt_item_outline),
                  SizedBox(height: 10.h),
                  _buildSheetCard(
                    padding: EdgeInsets.all(14.r),
                    child: Column(
                      children: [
                        _buildSheetPriceRow('Item total',
                            itemsTotal > 0 ? itemsTotal : grandTotal),
                        if (discountTotal > 0) ...[
                          SizedBox(height: 10.h),
                          _buildSheetPriceRow('Discount', discountTotal,
                              isDiscount: true),
                        ],
                        SizedBox(height: 10.h),
                        _buildSheetPriceRow('Delivery fee', shippingTotal,
                            freeWhenZero: true),
                        SizedBox(height: 12.h),
                        Divider(height: 1, color: AppColors.borderDisabled),
                        SizedBox(height: 12.h),
                        _buildSheetPriceRow('Total per delivery', grandTotal,
                            isTotal: true),
                        if (sub.paymentMethodTitle?.isNotEmpty == true) ...[
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundBase,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.card_outline,
                                    size: 13.sp, color: AppColors.textTertiary),
                                SizedBox(width: 8.w),
                                MyAppText(
                                  data: 'Paid via',
                                  size: 10.sp,
                                  weight: FontWeight.w500,
                                  color: AppColors.textTertiary,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: MyAppText(
                                    data: sub.paymentMethodTitle!,
                                    size: 10.sp,
                                    weight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSheetFooter(context, sub),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(
    BuildContext context,
    GetCustomerSubscriptionsResponseModel sub,
    Color statusColor,
    IconData statusIcon,
    String statusLabel,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDisabled),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderDisabled,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppText(
                      data: 'Subscription Details',
                      size: 14.sp,
                      weight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 3.h),
                    MyAppText(
                      data: '#${sub.id}',
                      size: 10.sp,
                      weight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11.sp, color: statusColor),
                    SizedBox(width: 5.w),
                    MyAppText(
                      data: statusLabel,
                      size: 10.sp,
                      weight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
              IconButton(
                constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                padding: EdgeInsets.all(6.r),
                icon: Icon(Icons.close,
                    size: 18.sp, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeroCard(
    GetCustomerSubscriptionsResponseModel sub,
    LineItem? heroItem,
    double grandTotal,
  ) {
    final itemCount = sub.lineItems?.length ?? 0;
    final title = itemCount > 1
        ? '${heroItem?.name?.toString() ?? 'Subscription'} + ${itemCount - 1} more'
        : (heroItem?.name?.toString() ?? 'Subscription');

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDisabled),
      ),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: heroItem?.image?.src != null
                ? MyAppCachedImage(
                    imageUrl: heroItem!.image!.src.toString(),
                    fit: BoxFit.contain,
                  )
                : Icon(Iconsax.box_outline,
                    size: 20.sp, color: AppColors.brandPrimary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyAppText(
                  data: title,
                  size: 12.5.sp,
                  weight: FontWeight.w700,
                  maxLines: 2,
                  lineHeight: 1.3,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 5.h),
                MyAppText(
                  data: 'Qty ${heroItem?.quantity ?? 1} per delivery',
                  size: 10.sp,
                  weight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyAppText(
                data: '₹${grandTotal.toStringAsFixed(2)}',
                size: 15.sp,
                weight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
              SizedBox(height: 2.h),
              MyAppText(
                data: 'per delivery',
                size: 9.sp,
                weight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheetCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDisabled),
      ),
      child: child,
    );
  }

  Widget _buildSheetSectionTitle(String title, IconData icon,
      {String? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.brandPrimary),
        SizedBox(width: 7.w),
        Expanded(
          child: MyAppText(
            data: title,
            size: 12.sp,
            weight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null)
          MyAppText(
            data: trailing,
            size: 10.sp,
            weight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
      ],
    );
  }

  Widget _buildSheetNotice({
    required Color color,
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: color),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyAppText(
                  data: title,
                  size: 10.5.sp,
                  weight: FontWeight.w700,
                  maxLines: 2,
                  lineHeight: 1.35,
                  color: color,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  MyAppText(
                    data: subtitle,
                    size: 9.5.sp,
                    weight: FontWeight.w500,
                    maxLines: 2,
                    lineHeight: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetDetailRow({
    required IconData icon,
    required String label,
    String? value,
    bool isLast = false,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderDisabled),
              ),
            ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textTertiary),
          SizedBox(width: 9.w),
          MyAppText(
            data: label,
            size: 10.5.sp,
            weight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: MyAppText(
              data: hasValue ? value : 'Not set',
              size: 10.5.sp,
              align: TextAlign.right,
              weight: FontWeight.w600,
              fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
              maxLines: 2,
              color: hasValue ? AppColors.textPrimary : AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetLineItem(LineItem item) {
    final qty = item.quantity?.toString() ?? '1';
    final unitPrice = (item.price ?? 0).toDouble();
    final lineTotal =
        double.tryParse(item.total?.toString() ?? '') ?? unitPrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.backgroundBase,
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.image?.src != null
              ? MyAppCachedImage(
                  imageUrl: item.image!.src.toString(),
                  fit: BoxFit.contain,
                )
              : Icon(Iconsax.box_outline,
                  size: 18.sp, color: AppColors.textTertiary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyAppText(
                data: item.name?.toString() ?? 'Item',
                size: 11.5.sp,
                weight: FontWeight.w600,
                maxLines: 2,
                lineHeight: 1.3,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 4.h),
              MyAppText(
                data: '₹${unitPrice.toStringAsFixed(2)} × $qty',
                size: 10.sp,
                weight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        MyAppText(
          data: '₹${lineTotal.toStringAsFixed(2)}',
          size: 12.sp,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildSheetPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
    bool freeWhenZero = false,
  }) {
    final showFree = freeWhenZero && amount <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyAppText(
          data: label,
          size: isTotal ? 12.sp : 11.sp,
          weight: isTotal ? FontWeight.w700 : FontWeight.w500,
          color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
        ),
        MyAppText(
          data: showFree
              ? 'FREE'
              : isDiscount
                  ? '-₹${amount.toStringAsFixed(2)}'
                  : '₹${amount.toStringAsFixed(2)}',
          size: isTotal ? 14.sp : 11.sp,
          weight: isTotal ? FontWeight.bold : FontWeight.w600,
          color: showFree || isDiscount
              ? AppColors.success
              : (isTotal ? AppColors.brandPrimary : AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSheetFooter(
      BuildContext sheetContext, GetCustomerSubscriptionsResponseModel sub) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(top: BorderSide(color: AppColors.borderDisabled)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 42.h,
          child: _buildPillButton(
            icon: Iconsax.headphone_bold,
            label: 'Need help with this subscription?',
            filled: false,
            onTap: () {
              Navigator.pop(sheetContext);
              // Sheet context is gone after the pop — use the screen's context
              // so the launcher can still surface a failure snackbar.
              handleWhatsAppLauncher(
                BrandConfig.instance.content.whatsappNumber,
                'Hi, I need help with my Subscription #${sub.id}',
                context,
              );
            },
          ),
        ),
      ),
    );
  }

  String? _formatAddress(GetCustomerSubscriptionsResponseModel sub) {
    final billing = sub.billing;
    if (billing == null) return null;

    final cityLine = [billing.city, billing.state, billing.postcode]
        .map((e) => e?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join(', ');

    final lines = [billing.address1, billing.address2, cityLine]
        .map((e) => e?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    return lines.isEmpty ? null : lines.join('\n');
  }

  String? _billingCycleLabel(GetCustomerSubscriptionsResponseModel sub) {
    final period = sub.billingPeriod?.toString().trim().toLowerCase() ?? '';
    if (period.isEmpty) return null;

    final interval = int.tryParse(sub.billingInterval?.toString() ?? '') ?? 1;
    return interval <= 1 ? 'Every $period' : 'Every $interval ${period}s';
  }

  String? _formatDateValue(dynamic value) {
    final date = _tryParseDate(value);
    return date == null ? null : DateFormat('MMM d, yyyy').format(date);
  }

  double _toAmount(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;
}

class _PauseInfo {
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<DateTime> selectedDates;

  const _PauseInfo({
    this.rangeStart,
    this.rangeEnd,
    this.selectedDates = const [],
  });

  bool get isRange => rangeStart != null && rangeEnd != null;
  bool get hasSelectedDates => selectedDates.isNotEmpty;
}

_PauseInfo _extractPauseInfo(List<dynamic>? pauseDates) {
  if (pauseDates == null || pauseDates.isEmpty) return const _PauseInfo();

  final rangeEntries = pauseDates.whereType<Map>().toList();
  if (rangeEntries.isNotEmpty) {
    final entry = Map<String, dynamic>.from(rangeEntries.last);
    return _PauseInfo(
      rangeStart: _tryParseDate(entry['start'] ??
          entry['from'] ??
          entry['pause_start_date'] ??
          entry['start_date']),
      rangeEnd: _tryParseDate(entry['end'] ??
          entry['to'] ??
          entry['pause_end_date'] ??
          entry['end_date']),
    );
  }

  final dates = pauseDates
      .map((e) => _tryParseDate(e))
      .whereType<DateTime>()
      .toList()
    ..sort();
  return _PauseInfo(selectedDates: dates);
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}


