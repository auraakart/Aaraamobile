import 'dart:async';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/get_customer_order.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_cached_image.dart';
import 'package:aaraa_kart/presentation/common/my_app_date_range_picker.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/history/order_note.dart';
import 'package:aaraa_kart/presentation/widgets/build_cart_icon.dart';
import 'package:aaraa_kart/presentation/widgets/build_msg_widget.dart';
import 'package:aaraa_kart/presentation/widgets/generate_receipt.dart';
import 'package:aaraa_kart/presentation/widgets/order_history_filter.dart';
import 'package:aaraa_kart/presentation/widgets/whatsapp_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isInitialLoading = true;
  bool _isPaginationLoading = false;
  bool _isRefreshing = false;

  int _currentPage = 1;
  bool _hasReachedMax = false;

  List<HistoryProduct> _orderList = [];

  String? _errorMessage;

  DateTime? _filterFromDate;
  DateTime? _filterToDate;
  OrderTypeFilter _selectedOrderTypeFilter = OrderTypeFilter.both;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupScrollController();
    _initialLoad();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !_isPaginationLoading &&
          !_hasReachedMax &&
          _errorMessage == null) {
        _loadMoreOrders();
      }
    });
  }

  Future<void> _initialLoad() async {
    if (!mounted) return;

    if (context.read<StorageCubit>().isGuestMode != false) {
      setState(() {
        _isInitialLoading = false;
      });
      return;
    }

    final cachedState = context.read<OrderCubit>().state;
    if (cachedState is GetOrderListSuccess) {
      _handleOrderStateChanges(context, cachedState);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(page: 1, isInitial: true);
    });
  }

  Future<void> _fetchOrders({
    required int page,
    bool isInitial = false,
    bool isRefresh = false,
  }) async {
    if (!mounted) return;

    if (context.read<StorageCubit>().isGuestMode != false ||
        context.read<StorageCubit>().userData == null) {
      return;
    }

    setState(() {
      if (isInitial) {
        _isInitialLoading = true;
      } else if (isRefresh) {
        _isRefreshing = true;
      } else {
        _isPaginationLoading = true;
      }
      _errorMessage = null;
    });

    context.read<OrderCubit>().getOrderList(
        context.read<StorageCubit>().userData!.customerID.toString(),
        page,
        _filterFromDate ?? DateTime(2024, 1, 1),
        _filterToDate ?? DateTime.now());
  }

  Future<void> _loadMoreOrders() async {
    if (_hasReachedMax || _isPaginationLoading) return;
    await _fetchOrders(page: _currentPage);
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _currentPage = 1;
      _hasReachedMax = false;
      _orderList.clear();
    });
    await _fetchOrders(page: 1, isRefresh: true);
  }

  Future<void> _applyDateFilter() async {
    final result = await myAppOrderDateRangePicker(
        context, _filterFromDate, _filterToDate);
    if (result != null && mounted) {
      setState(() {
        _filterFromDate = result['fromDate'];
        _filterToDate = result['toDate'];
        _currentPage = 1;
        _hasReachedMax = false;
        _orderList.clear();
      });
      await _fetchOrders(page: 1, isInitial: true);
    }
  }

  void _clearDateFilter() {
    if (_filterFromDate != null || _filterToDate != null) {
      setState(() {
        _filterFromDate = null;
        _filterToDate = null;
        _currentPage = 1;
        _hasReachedMax = false;
        _orderList.clear();
      });
      _fetchOrders(page: 1, isInitial: true);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedOrderTypeFilter = OrderTypeFilter.both;
      if (_filterFromDate != null || _filterToDate != null) {
        _filterFromDate = null;
        _filterToDate = null;
        _currentPage = 1;
        _hasReachedMax = false;
        _orderList.clear();
        _fetchOrders(page: 1, isInitial: true);
      }
    });
  }

  bool _isSubscriptionOrder(HistoryProduct order) {
    final type = order.orderType?.trim().toLowerCase();
    return type == 'parent' || type == 'renewal';
  }

  bool _isOneTimeOrder(HistoryProduct order) {
    final type = order.orderType?.trim().toLowerCase();
    return type == 'one_time' || type == 'onetime' || type == 'one-time';
  }

  List<HistoryProduct> _getFilteredOrders() {
    return _orderList.where((order) {
      if (_filterFromDate != null && _filterToDate != null) {
        final orderDate = order.dateCreated;
        if (orderDate == null) return false;

        final startOfDay = DateTime(_filterFromDate!.year,
            _filterFromDate!.month, _filterFromDate!.day);
        final endOfDay = DateTime(_filterToDate!.year, _filterToDate!.month,
            _filterToDate!.day, 23, 59, 59);

        final matches = orderDate
                .isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            orderDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
        if (!matches) return false;
      }

      if (_selectedOrderTypeFilter == OrderTypeFilter.subscription) {
        return _isSubscriptionOrder(order);
      }
      if (_selectedOrderTypeFilter == OrderTypeFilter.oneTime) {
        return _isOneTimeOrder(order);
      }

      return true;
    }).toList();
  }

  void _showOrderTypeFilterSheet() {
    OrderHistoryFilterSheet.show(
      context: context,
      currentFilter: _selectedOrderTypeFilter,
      onFilterSelected: (newFilter) {
        if (_selectedOrderTypeFilter != newFilter) {
          setState(() {
            _selectedOrderTypeFilter = newFilter;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGuestMode = context.read<StorageCubit>().isGuestMode != false;

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: MyAppBar(
        showLeading: false,
        centerTitle: false,
        title: MyAppText(data: 'Order History'),
        actions: [
          if (!isGuestMode) ...[
            IconButton(
              icon: Icon(
                _selectedOrderTypeFilter != OrderTypeFilter.both
                    ? Iconsax.filter_tick_bold
                    : Iconsax.filter_search_outline,
                color: _selectedOrderTypeFilter != OrderTypeFilter.both
                    ? AppColors.brandPrimary
                    : AppColors.textSecondary,
                size: 20.r,
              ),
              onPressed: _showOrderTypeFilterSheet,
              tooltip: 'Filter orders',
            ),
            IconButton(
              icon: Icon(
                _filterFromDate != null
                    ? Iconsax.calendar_tick_bold
                    : Iconsax.calendar_search_outline,
                color: _filterFromDate != null
                    ? AppColors.brandPrimary
                    : AppColors.textSecondary,
                size: 20.r,
              ),
              onPressed: _applyDateFilter,
              tooltip: 'Filter by date',
            ),
          ],
          CartIconButton(),
        ],
      ),
      body: isGuestMode
          ? _buildGuestModeView()
          : BlocConsumer<OrderCubit, OrderState>(
              listener: _handleOrderStateChanges,
              builder: (context, state) => _buildMainContent(),
            ),
    );
  }

  Widget _buildGuestModeView() {
    return Center(
      child: buildMsgState(
        context,
        'You are not signed in',
        'Continue signing in to view your orders',
        () => context.push('/login', extra: {'guestMode': true}),
        'Sign In',
        Iconsax.lock_outline,
      ),
    );
  }

  void _handleOrderStateChanges(BuildContext context, OrderState state) {
    if (state is GetOrderListLoading) {
      return;
    }

    if (state is GetOrderListSuccess) {
      final newItems = state.orderListResponse ?? [];

      setState(() {
        if (state.currentPage == 1) {
          _orderList = [...newItems];
        } else {
          _orderList.addAll(newItems);
        }

        _currentPage = state.currentPage + 1;
        _hasReachedMax = state.currentPage >= state.totalPage;

        _isInitialLoading = false;
        _isPaginationLoading = false;
        _isRefreshing = false;
        _errorMessage = null;
      });
    }

    if (state is GetOrderListError) {
      setState(() {
        _errorMessage = state.message;
        _isInitialLoading = false;
        _isPaginationLoading = false;
        _isRefreshing = false;
      });

      if (_orderList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _fetchOrders(page: 1, isInitial: true),
            ),
          ),
        );
      }
    }
  }

  Widget _buildMainContent() {
    if (_isInitialLoading && _orderList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.brandPrimary,
        ),
      );
    }

    if (_errorMessage != null && _orderList.isEmpty) {
      return Center(
        child: buildMsgState(
          context,
          'Oops! Something went wrong',
          _errorMessage!,
          () => _fetchOrders(page: 1, isInitial: true),
          'Try Again',
          Iconsax.danger_outline,
        ),
      );
    }

    final filteredOrders = _getFilteredOrders();
    final hasActiveFilter =
        (_filterFromDate != null && _filterToDate != null) ||
            _selectedOrderTypeFilter != OrderTypeFilter.both;

    if (filteredOrders.isEmpty && !_isRefreshing) {
      String title = 'No orders yet';
      String subtitle =
          'Your order history will appear here once you make your first purchase';
      VoidCallback buttonAction = () => context.push('/bottom-bar');
      String buttonText = 'Browse Products';
      IconData icon = Iconsax.menu_board_bold;

      if (hasActiveFilter) {
        title = 'No orders found';
        if (_selectedOrderTypeFilter == OrderTypeFilter.subscription) {
          subtitle = 'No subscription orders found for the current filter';
        } else if (_selectedOrderTypeFilter == OrderTypeFilter.oneTime) {
          subtitle = 'No one-time orders found for the current filter';
        } else {
          subtitle = 'No orders found for the selected date range';
        }
        buttonAction = _clearAllFilters;
        buttonText = 'Clear Filters';
        icon = Iconsax.refresh_outline;
      }

      return Center(
        child: buildMsgState(
          context,
          title,
          subtitle,
          buttonAction,
          buttonText,
          icon,
        ),
      );
    }

    return Column(
      children: [
        _buildActiveFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshOrders,
            color: AppColors.brandPrimary,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.r),
              itemCount: filteredOrders.length + (_isPaginationLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < filteredOrders.length) {
                  return _buildOrderCard(context, filteredOrders[index]);
                }
                return _buildPaginationLoader();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilterChips() {
    final hasTypeFilter = _selectedOrderTypeFilter != OrderTypeFilter.both;
    final hasDateFilter = _filterFromDate != null && _filterToDate != null;

    if (!hasTypeFilter && !hasDateFilter) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (hasTypeFilter) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.textPrimary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedOrderTypeFilter == OrderTypeFilter.subscription
                          ? Iconsax.calendar_1_outline
                          : Iconsax.shopping_bag_outline,
                      size: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 6.w),
                    MyAppText(
                      data: _selectedOrderTypeFilter ==
                              OrderTypeFilter.subscription
                          ? 'Subscription Orders'
                          : 'One-Time Orders',
                      size: 11.sp,
                      weight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 6.w),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedOrderTypeFilter = OrderTypeFilter.both;
                        });
                      },
                      child: Icon(
                        Iconsax.close_circle_bold,
                        size: 15.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
            ],
            if (hasDateFilter) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.calendar_tick_bold,
                      size: 13.sp,
                      color: AppColors.brandPrimary,
                    ),
                    SizedBox(width: 6.w),
                    MyAppText(
                      data:
                          '${DateFormat('MMM d').format(_filterFromDate!)} - ${DateFormat('MMM d, yyyy').format(_filterToDate!)}',
                      size: 11.sp,
                      weight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                    SizedBox(width: 6.w),
                    InkWell(
                      onTap: _clearDateFilter,
                      child: Icon(
                        Iconsax.close_circle_bold,
                        size: 15.sp,
                        color: AppColors.brandPrimary,
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

  Widget _buildPaginationLoader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: AppColors.brandPrimary,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, HistoryProduct order) {
    final lineItems = order.lineItems ?? [];
    final itemCount = lineItems.length;
    final productNames = lineItems.map((e) => e.name).join(', ');
    final firstImageSrc =
        lineItems.isNotEmpty ? lineItems.first.image?.src : null;

    final orderDateStr = _formatOrderDate(order);
    final deliveryInfo = _getDeliveryDateInfo(order);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: firstImageSrc != null
                    ? MyAppCachedImage(
                        imageUrl: firstImageSrc.toString(),
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        Iconsax.shopping_bag_outline,
                        size: 18.sp,
                        color: AppColors.brandPrimary,
                      ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppText(
                      data: productNames,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      weight: FontWeight.w600,
                      size: 12.sp,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          order.paymentMethod == 'cod'
                              ? Iconsax.truck_fast_bold
                              : Iconsax.wallet_2_bold,
                          size: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                                ),
                                if (orderDateStr.isNotEmpty) ...[
                                  const TextSpan(text: ' · Ordered: '),
                                  TextSpan(
                                    text: orderDateStr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (deliveryInfo.date.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.only(left: 14.w),
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: '| ${deliveryInfo.prefix}',
                              ),
                              TextSpan(
                                text: deliveryInfo.date,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              MyAppText(
                data: '₹${order.total}',
                weight: FontWeight.bold,
                size: 13.sp,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildOrderTrackingTimeline(
            order.status.toString(),
            order.status?.toLowerCase().trim() == 'cancelled' ||
                order.status?.toLowerCase().trim() == 'failed',
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    order.paymentMethod == 'cod'
                        ? Iconsax.truck_fast_bold
                        : Iconsax.wallet_2_bold,
                    size: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 5.w),
                  MyAppText(
                    data: (order.paymentMethodTitle != null &&
                            order.paymentMethodTitle != '')
                        ? order.paymentMethodTitle.toString()
                        : (order.paymentMethod == 'cod'
                            ? 'Cash on Delivery'
                            : 'Online Payment'),
                    weight: FontWeight.w600,
                    size: 9.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              MyAppText(
                data: '#${order.id}',
                weight: FontWeight.w500,
                size: 9.sp,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(height: 1, color: AppColors.borderDisabled),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildPillButton(
                  icon: Iconsax.message_2_outline,
                  label: 'Order Notes',
                  filled: false,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) =>
                        OrderNotesBottomSheet(orderId: order.id.toString()),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildPillButton(
                  label: 'View Details',
                  trailingIcon: Icons.chevron_right,
                  filled: true,
                  onTap: () => _showOrderDetails(context, order),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTrackingTimeline(String currentStatus, bool isCancelled) {
    final lowerStatus = currentStatus.toLowerCase().trim();
    final isRefunded = lowerStatus == 'refunded';
    final statuses = isRefunded
        ? ['pending', 'refunded']
        : (isCancelled || lowerStatus == 'cancelled' || lowerStatus == 'failed'
            ? ['pending', 'cancelled']
            : ['pending', 'processing', 'completed']);

    final currentIndex = statuses.indexOf(lowerStatus);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(statuses.length * 2 - 1, (index) {
        if (index.isEven) {
          final statusIndex = index ~/ 2;
          final isActive = statusIndex <= currentIndex;
          final status = statuses[statusIndex];

          return _buildTrackingStep(
            icon: _getStatusIconForTracking(status),
            label: _getStatusLabelForTracking(status),
            isActive: isActive,
            color: (isCancelled && (status == 'cancelled' || status == 'failed'))
                ? AppColors.error
                : ((isRefunded && status == 'refunded')
                    ? _getStatusColor('refunded')
                    : (isActive
                        ? _getStatusColor(currentStatus)
                        : AppColors.borderDefault)),
          );
        }

        final isActive = (index ~/ 2) < currentIndex;
        final lineColor = (isCancelled && currentIndex == 1)
            ? AppColors.error.withOpacity(0.3)
            : ((isRefunded && currentIndex == 1)
                ? _getStatusColor('refunded').withOpacity(0.3)
                : (isActive
                    ? _getStatusColor(currentStatus)
                    : AppColors.borderDefault));

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Container(height: 2.h, color: lineColor),
          ),
        );
      }),
    );
  }

  Widget _buildTrackingStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 17.w,
          height: 17.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color : AppColors.borderDefault,
              width: 1.5,
            ),
          ),
          child: isActive ? Icon(icon, size: 9.sp, color: Colors.white) : null,
        ),
        SizedBox(height: 4.h),
        MyAppText(
          data: label,
          size: 8.sp,
          weight: FontWeight.w600,
          color: isActive ? color : AppColors.textTertiary,
        ),
      ],
    );
  }

  IconData _getStatusIconForTracking(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return Iconsax.clock_outline;
      case 'processing':
        return Iconsax.truck_time_bold;
      case 'completed':
        return Iconsax.truck_tick_bold;
      case 'cancelled':
      case 'failed':
        return Iconsax.close_circle_bold;
      case 'refunded':
        return Iconsax.money_recive_outline;
      default:
        return Iconsax.info_circle_outline;
    }
  }

  String _getStatusLabelForTracking(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status.isEmpty
            ? 'Unknown'
            : status[0].toUpperCase() + status.substring(1);
    }
  }

  Widget _buildPillButton({
    required String label,
    required bool filled,
    required VoidCallback onTap,
    IconData? icon,
    IconData? trailingIcon,
  }) {
    final backgroundColor =
        filled ? AppColors.brandPrimary : AppColors.backgroundBase;
    final foregroundColor = filled ? Colors.white : AppColors.textSecondary;

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
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12.sp, color: foregroundColor),
              SizedBox(width: 5.w),
            ],
            MyAppText(
              data: label,
              weight: FontWeight.w600,
              size: 10.sp,
              color: foregroundColor,
            ),
            if (trailingIcon != null) ...[
              SizedBox(width: 3.w),
              Icon(trailingIcon, size: 12.sp, color: foregroundColor),
            ],
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, HistoryProduct order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            _buildDetailsSheet(context, order, scrollController),
      ),
    );
  }

  Widget _buildDetailsSheet(
    BuildContext sheetContext,
    HistoryProduct order,
    ScrollController scrollController,
  ) {
    final status = order.status?.toString() ?? '';
    final isCancelled =
        status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'failed';
    final isRefunded = status.toLowerCase() == 'refunded';
    final statusColor = isCancelled
        ? AppColors.error
        : (isRefunded ? _getStatusColor('refunded') : _getStatusColor(status));

    final lineItems = order.lineItems ?? [];

    final itemsTotal = lineItems.fold<double>(0, (sum, item) {
      final lineTotal = double.tryParse(item.total?.toString() ?? '');
      if (lineTotal != null) return sum + lineTotal;
      final price = double.tryParse(item.price?.toString() ?? '') ?? 0;
      return sum + price * (item.quantity ?? 1);
    });
    final shippingTotal = _toAmount(order.shippingTotal);
    final discountTotal = _toAmount(order.discountTotal);
    final grandTotal = _toAmount(order.total);

    final address = _formatAddress(order.billing);
    final recipient = [order.billing?.firstName, order.billing?.lastName]
        .map((e) => e?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join(' ');
    final phone = order.billing?.phone?.trim() ?? '';
    final customerNote = order.customerNote?.trim() ?? '';

    final paymentLabel = (order.paymentMethodTitle?.isNotEmpty == true)
        ? order.paymentMethodTitle!
        : (order.paymentMethod == 'cod'
            ? 'Cash on Delivery'
            : 'Online Payment');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildSheetHeader(sheetContext, order, statusColor, status),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHeroCard(order, lineItems, grandTotal),
                  SizedBox(height: 12.h),
                  _buildSheetCard(
                    padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
                    child: _buildOrderTrackingTimeline(status, isCancelled),
                  ),
                  if (customerNote.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildSheetNotice(
                      color: AppColors.brandPrimary,
                      icon: Iconsax.note_2_outline,
                      title: 'Your note',
                      subtitle: customerNote,
                    ),
                  ],
                  SizedBox(height: 20.h),
                  _buildSheetSectionTitle(
                      'Order Info', Iconsax.receipt_2_outline),
                  SizedBox(height: 10.h),
                  _buildSheetCard(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Column(
                      children: [
                        _buildSheetDetailRow(
                          icon: Iconsax.hashtag_outline,
                          label: 'Order number',
                          value: '#${order.id}',
                        ),
                        _buildSheetDetailRow(
                          icon: Iconsax.calendar_1_outline,
                          label: 'Order Date',
                          value: _formatDate(order.dateCreated),
                        ),
                        if (order.datePaid != null)
                          _buildSheetDetailRow(
                            icon: Iconsax.money_recive_outline,
                            label: 'Paid on',
                            value: _formatDate(order.datePaid),
                          ),
                        if (_isOrderRefunded(order)) ...[
                          if (_getRefundDate(order) != null)
                            _buildSheetDetailRow(
                              icon: Iconsax.calendar_tick_outline,
                              label: 'Refunded on',
                              value: _getRefundDate(order),
                            ),
                          if (_getRefundAmount(order) != null)
                            _buildSheetDetailRow(
                              icon: Iconsax.money_recive_outline,
                              label: 'Refund Amount',
                              value: _getRefundAmount(order),
                            ),
                          if (_getRefundReason(order) != null)
                            _buildSheetDetailRow(
                              icon: Iconsax.note_2_outline,
                              label: 'Refund Reason',
                              value: _getRefundReason(order),
                            ),
                        ] else if (_isOrderCancelled(order)) ...[
                          if (_getCancelledDate(order) != null)
                            _buildSheetDetailRow(
                              icon: Iconsax.close_circle_outline,
                              label: 'Cancelled Date',
                              value: _getCancelledDate(order),
                            ),
                        ] else if (_isOrderDelivered(order)) ...[
                          if (_getActualDeliveryDate(order) != null)
                            _buildSheetDetailRow(
                              icon: Iconsax.truck_tick_outline,
                              label: 'Delivered on',
                              value: _getActualDeliveryDate(order),
                            ),
                        ] else ...[
                          if (_getScheduledDeliveryDate(order) != null)
                            _buildSheetDetailRow(
                              icon: Iconsax.calendar_tick_outline,
                              label: 'Delivery Date',
                              value: _getScheduledDeliveryDate(order),
                            ),
                        ],
                        if (_getDeliverySlot(order) != null &&
                            _getDeliverySlot(order)!.isNotEmpty)
                          _buildSheetDetailRow(
                            icon: Iconsax.clock_outline,
                            label: 'Delivery Slot',
                            value: _getDeliverySlot(order),
                          ),
                        _buildSheetDetailRow(
                          icon: order.paymentMethod == 'cod'
                              ? Iconsax.truck_fast_bold
                              : Iconsax.wallet_2_bold,
                          label: 'Payment',
                          value: paymentLabel,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSheetSectionTitle(
                    'Items',
                    Iconsax.shopping_bag_outline,
                    trailing:
                        '${lineItems.length} ${lineItems.length == 1 ? 'item' : 'items'}',
                  ),
                  SizedBox(height: 10.h),
                  _buildSheetCard(
                    padding: EdgeInsets.all(14.r),
                    child: lineItems.isEmpty
                        ? MyAppText(
                            data: 'No items in this order',
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
                            color: AppColors.brandPrimary.withOpacity(0.08),
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
                      'Price Details', Iconsax.receipt_item_outline),
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
                        _buildSheetPriceRow('Total amount', grandTotal,
                            isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSheetFooter(sheetContext, order),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(
    BuildContext sheetContext,
    HistoryProduct order,
    Color statusColor,
    String status,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(bottom: BorderSide(color: AppColors.borderDisabled)),
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
                      data: 'Order Details',
                      size: 14.sp,
                      weight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 3.h),
                    MyAppText(
                      data: '#${order.id}',
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIconForTracking(status),
                        size: 11.sp, color: statusColor),
                    SizedBox(width: 5.w),
                    MyAppText(
                      data: _getStatusLabelForTracking(status),
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
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeroCard(
    HistoryProduct order,
    List<LineItem> lineItems,
    double grandTotal,
  ) {
    final firstImageSrc =
        lineItems.isNotEmpty ? lineItems.first.image?.src : null;
    final productNames = lineItems.map((e) => e.name).join(', ');

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
              color: AppColors.brandPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: firstImageSrc != null
                ? MyAppCachedImage(
                    imageUrl: firstImageSrc.toString(),
                    fit: BoxFit.contain,
                  )
                : Icon(Iconsax.shopping_bag_outline,
                    size: 20.sp, color: AppColors.brandPrimary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyAppText(
                  data: productNames.isEmpty ? 'Order' : productNames,
                  size: 12.5.sp,
                  weight: FontWeight.w700,
                  maxLines: 2,
                  lineHeight: 1.3,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 5.h),
                MyAppText(
                  data: order.dateCreated != null
                      ? 'Placed ${DateFormat('MMM d, yyyy').format(order.dateCreated!)}'
                      : '${lineItems.length} ${lineItems.length == 1 ? 'item' : 'items'}',
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
                data: 'order total',
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
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.18)),
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
                    maxLines: 4,
                    lineHeight: 1.4,
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
              border:
                  Border(bottom: BorderSide(color: AppColors.borderDisabled)),
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
              data: hasValue ? value : 'Not available',
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
    final qty = item.quantity ?? 1;
    final unitPrice = double.tryParse(item.price?.toString() ?? '') ?? 0;
    final lineTotal =
        double.tryParse(item.total?.toString() ?? '') ?? unitPrice * qty;

    return Row(
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

  Widget _buildSheetFooter(BuildContext sheetContext, HistoryProduct order) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(top: BorderSide(color: AppColors.borderDisabled)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42.h,
                child: _buildPillButton(
                  icon: Iconsax.headphone_bold,
                  label: 'Need Help?',
                  filled: false,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    // Sheet context is gone after the pop — use the screen's
                    // context so the launcher can still show a failure message.
                    handleWhatsAppLauncher(
                      BrandConfig.instance.content.whatsappNumber,
                      'Hi, I Need help on this Order #${order.id}',
                      context,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: SizedBox(
                height: 42.h,
                child: _buildPillButton(
                  icon: Iconsax.document_download_outline,
                  label: 'Receipt',
                  filled: true,
                  onTap: () => _downloadReceipt(order),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadReceipt(HistoryProduct order) async {
    final billing = order.billing;
    final addressParts = [billing?.address1, billing?.address2]
        .map((e) => e?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join(' - ');

    await Printing.layoutPdf(
      name: 'Order-${order.id}',
      onLayout: (PdfPageFormat format) async => await generateInvoicePdf(
        format: PdfPageFormat.a4,
        invoiceNumber: order.id.toString(),
        invoiceDate: DateFormat('dd MMMM yyyy').format(DateTime.now()),
        orderNumber: order.id.toString(),
        orderDate: DateFormat('dd MMMM yyyy')
            .format(order.dateCreated ?? DateTime.now()),
        paymentMethod: order.paymentMethodTitle ?? '',
        customerName: [billing?.firstName, billing?.lastName]
            .map((e) => e?.trim() ?? '')
            .where((e) => e.isNotEmpty)
            .join(' '),
        customerAddress: addressParts,
        contactNumber: billing?.phone ?? '',
        items: (order.lineItems ?? []).map((item) {
          return DairyProduct(
            name: item.name ?? 'Item',
            quantity: item.quantity ?? 1,
            rate: double.tryParse(item.price?.toString() ?? '') ?? 0,
          );
        }).toList(),
      ),
    );
  }

  String? _formatAddress(Ing? billing) {
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

  bool _isOrderDelivered(HistoryProduct order) {
    final status = order.status?.toLowerCase().trim() ?? '';
    final deliveryStatus = order.deliveryStatus?.toLowerCase().trim() ?? '';
    return status == 'completed' ||
        status == 'delivered' ||
        deliveryStatus == 'delivered';
  }

  bool _isOrderCancelled(HistoryProduct order) {
    final status = order.status?.toLowerCase().trim() ?? '';
    return status == 'cancelled' || status == 'failed';
  }

  bool _isOrderRefunded(HistoryProduct order) {
    final status = order.status?.toLowerCase().trim() ?? '';
    return status == 'refunded';
  }

  String _formatOrderDate(HistoryProduct order) {
    final date = order.dateCreated ?? order.dateCreatedGmt;
    if (date != null) {
      return DateFormat('MMM d, yyyy').format(date);
    }
    return '';
  }

  ({String prefix, String date}) _getDeliveryDateInfo(HistoryProduct order) {
    final status = order.status?.toLowerCase().trim() ?? '';
    final deliveryStatus = order.deliveryStatus?.toLowerCase().trim() ?? '';
    final isDelivered = status == 'completed' ||
        status == 'delivered' ||
        deliveryStatus == 'delivered';
    final isCancelled = status == 'cancelled' || status == 'failed';
    final isRefunded = status == 'refunded';

    if (isDelivered) {
      return (
        prefix: 'Delivered: ',
        date: _getDeliveredDateFormatted(order),
      );
    } else if (isCancelled) {
      return (
        prefix: 'Cancelled: ',
        date: _getCancelledDateFormatted(order),
      );
    } else if (isRefunded) {
      return (
        prefix: 'Refunded: ',
        date: _getCancelledDateFormatted(order),
      );
    } else {
      return (
        prefix: 'Est. Delivery: ',
        date: _getEstimatedDeliveryDateFormatted(order),
      );
    }
  }

  String _getDeliveredDateFormatted(HistoryProduct order) {
    if (order.dateCompleted != null) {
      return DateFormat('MMM d, yyyy').format(order.dateCompleted!);
    }
    if (order.dateCompletedGmt != null) {
      return DateFormat('MMM d, yyyy').format(order.dateCompletedGmt!);
    }
    if (order.metaData != null) {
      for (final meta in order.metaData!) {
        final key = meta.key?.toLowerCase() ?? '';
        if (key == 'date_completed' ||
            key == 'delivered_date' ||
            key == 'actual_delivery_date' ||
            key == '_delivered_date') {
          final val = meta.value?.toString().trim();
          if (val != null && val.isNotEmpty) {
            final parsed = _tryParseDate(val);
            if (parsed != null) {
              return DateFormat('MMM d, yyyy').format(parsed);
            }
          }
        }
      }
    }
    if (order.dateModified != null) {
      return DateFormat('MMM d, yyyy').format(order.dateModified!);
    }
    return _getEstimatedDeliveryDateFormatted(order);
  }

  String _getCancelledDateFormatted(HistoryProduct order) {
    if (order.dateModified != null) {
      return DateFormat('MMM d, yyyy').format(order.dateModified!);
    }
    if (order.dateModifiedGmt != null) {
      return DateFormat('MMM d, yyyy').format(order.dateModifiedGmt!);
    }
    if (order.metaData != null) {
      for (final meta in order.metaData!) {
        final key = meta.key?.toLowerCase() ?? '';
        if (key == 'cancelled_date' ||
            key == '_cancelled_date' ||
            key == 'date_cancelled') {
          final val = meta.value?.toString().trim();
          if (val != null && val.isNotEmpty) {
            final parsed = _tryParseDate(val);
            if (parsed != null) {
              return DateFormat('MMM d, yyyy').format(parsed);
            }
          }
        }
      }
    }
    if (order.dateCreated != null) {
      return DateFormat('MMM d, yyyy').format(order.dateCreated!);
    }
    return '';
  }

  String _getEstimatedDeliveryDateFormatted(HistoryProduct order) {
    DateTime? explicitDeliveryDate;
    bool isInstant = false;

    final customerNote = order.customerNote?.toLowerCase() ?? '';
    if (customerNote.contains('instant')) {
      isInstant = true;
    }

    if (order.metaData != null) {
      for (final meta in order.metaData!) {
        final key = meta.key?.toLowerCase() ?? '';
        final val = meta.value?.toString().trim() ?? '';
        if (key == 'delivery_date' ||
            key == '_delivery_date' ||
            key == 'delivery-date' ||
            key == 'scheduled_order_date' ||
            key == 'jckwds_date') {
          explicitDeliveryDate = _tryParseDate(val);
        }
        if (key.contains('delivery_type') ||
            key.contains('order_type') ||
            key == '_delivery_type' ||
            key == '_order_type') {
          if (val.toLowerCase().contains('instant')) {
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

    final orderDate =
        order.dateCreated ?? order.dateCreatedGmt ?? DateTime.now();

    if (isInstant) {
      return DateFormat('MMM d, yyyy').format(orderDate);
    } else if (explicitDeliveryDate != null) {
      return DateFormat('MMM d, yyyy').format(explicitDeliveryDate);
    } else {
      // Default standard delivery is order date + 1 day
      final nextDay = orderDate.add(const Duration(days: 1));
      return DateFormat('MMM d, yyyy').format(nextDay);
    }
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    try {
      return DateTime.parse(str);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd').parse(str);
      } catch (_) {
        try {
          return DateFormat('MMM d, yyyy').parse(str);
        } catch (_) {
          return null;
        }
      }
    }
  }

  String? _getScheduledDeliveryDate(HistoryProduct order) {
    final formatted = _getEstimatedDeliveryDateFormatted(order);
    return formatted.isNotEmpty ? formatted : null;
  }

  String? _getActualDeliveryDate(HistoryProduct order) {
    if (order.dateCompleted != null) {
      return _formatDate(order.dateCompleted);
    }
    if (order.metaData != null) {
      for (final meta in order.metaData!) {
        if (meta.key == 'date_completed' ||
            meta.key == 'delivered_date' ||
            meta.key == 'actual_delivery_date' ||
            meta.key == '_delivered_date') {
          final val = meta.value?.toString().trim();
          if (val != null && val.isNotEmpty) {
            try {
              final dt = DateTime.parse(val);
              return _formatDate(dt);
            } catch (_) {
              return val;
            }
          }
        }
      }
    }
    if (_isOrderDelivered(order) && order.dateModified != null) {
      return _formatDate(order.dateModified);
    }
    return null;
  }

  String? _getCancelledDate(HistoryProduct order) {
    if (order.metaData != null) {
      for (final meta in order.metaData!) {
        final key = meta.key?.toLowerCase() ?? '';
        if (key == 'cancelled_date' ||
            key == '_cancelled_date' ||
            key == 'date_cancelled' ||
            key == '_date_cancelled') {
          final val = meta.value?.toString().trim();
          if (val != null && val.isNotEmpty) {
            final parsed = _tryParseDate(val);
            if (parsed != null) {
              return _formatDate(parsed);
            }
            return val;
          }
        }
      }
    }
    if (order.dateModified != null) {
      return _formatDate(order.dateModified);
    }
    if (order.dateModifiedGmt != null) {
      return _formatDate(order.dateModifiedGmt);
    }
    if (order.dateCreated != null) {
      return _formatDate(order.dateCreated);
    }
    return null;
  }

  String? _getDeliverySlot(HistoryProduct order) {
    if (order.metaData != null) {
      for (final meta in order.metaData!) {
        if (meta.key == 'delivery_slot' || meta.key == '_delivery_slot') {
          final val = meta.value?.toString().trim();
          if (val != null && val.isNotEmpty) return val;
        }
      }
    }
    return null;
  }

  String? _getRefundDate(HistoryProduct order) {
    if (order.dateModified != null) {
      return _formatDate(order.dateModified);
    }
    if (order.dateModifiedGmt != null) {
      return _formatDate(order.dateModifiedGmt);
    }
    if (order.dateCreated != null) {
      return _formatDate(order.dateCreated);
    }
    return null;
  }

  String? _getRefundAmount(HistoryProduct order) {
    if (order.refunds != null && order.refunds!.isNotEmpty) {
      final totalRefund = order.refunds!.fold<double>(0.0, (sum, r) {
        final amount = double.tryParse(r.total?.toString() ?? '') ?? 0.0;
        return sum + amount.abs();
      });
      if (totalRefund > 0) {
        return '₹${totalRefund.toStringAsFixed(2)}';
      }
    }
    if (order.total != null && order.total!.isNotEmpty) {
      final amount = double.tryParse(order.total.toString()) ?? 0.0;
      if (amount > 0) {
        return '₹${amount.toStringAsFixed(2)}';
      }
    }
    return null;
  }

  String? _getRefundReason(HistoryProduct order) {
    if (order.refunds != null && order.refunds!.isNotEmpty) {
      final reasons = order.refunds!
          .map((r) => r.reason?.trim())
          .where((r) => r != null && r.isNotEmpty)
          .cast<String>()
          .toList();
      if (reasons.isNotEmpty) {
        return reasons.join(', ');
      }
    }
    return null;
  }

  String? _formatDate(DateTime? date) =>
      date == null ? null : DateFormat('MMM d, yyyy · h:mm a').format(date);

  double _toAmount(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      case 'refunded':
        return const Color(0xFF7B1FA2);
      default:
        return Colors.blue;
    }
  }
}
