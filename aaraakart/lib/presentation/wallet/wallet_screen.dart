import 'package:aaraa_kart/app/theme/app_colors.dart';

import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_state.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_cubit.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_state.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/get_wallet_transactions_model.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_shimmer.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/common/my_app_text_field.dart';
import 'package:aaraa_kart/presentation/payment/payment_gateway.dart';
import 'package:aaraa_kart/presentation/widgets/build_cart_icon.dart';
import 'package:aaraa_kart/presentation/widgets/build_msg_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  final String _currency = "₹";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (context.read<StorageCubit>().isGuestMode == false) {
      _loadWalletData();
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadWalletData() {
    final customerId = context.read<StorageCubit>().userData?.customerID;
    if (customerId != null && customerId.isNotEmpty) {
      context.read<WalletCubit>().getWalletAmount(customerId);
      context.read<WalletCubit>().getWalletTransactions(customerId);
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: _currency,
      decimalDigits: 2,
      locale: 'en_IN',
    ).format(amount);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('dd MMM yyyy, h:mm a').format(date);
    }
  }

  Widget _buildAmountButton(double amount, TextEditingController controller) {
    return Flexible(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            controller.text = amount.toStringAsFixed(0);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [
              //     AppColors.brandPrimary.withOpacity(0.1),
              //     AppColors.brandPrimary.withOpacity(0.05),
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.brandPrimary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: MyAppText(
                data: _formatCurrency(amount),
                size: 9.sp,
                weight: FontWeight.w600,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.brandPrimary,
                AppColors.brandPrimary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -30,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.wallet_3_bold,
                          color: Colors.white70,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        MyAppText(
                          data: 'Available Balance',
                          color: Colors.white70,
                          size: 13.sp,
                          weight: FontWeight.w500,
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        BlocConsumer<WalletCubit, WalletState>(
                          listener: (context, state) {},
                          buildWhen: (previous, current) {
                            return current is GetWalletAmountLoading ||
                                current is GetWalletAmountSuccess ||
                                current is GetWalletAmountError ||
                                current is UpdateWalletAmountSuccess;
                          },
                          builder: (context, state) {
                            String walletAmountStr =
                                context.read<WalletCubit>().cachedAmount ?? '0';
                            if (state is GetWalletAmountSuccess &&
                                state.walletAmount.isNotEmpty) {
                              walletAmountStr = state.walletAmount;
                            } else if (state is UpdateWalletAmountSuccess &&
                                state.walletResponse?.balance != null &&
                                state.walletResponse!.balance!.isNotEmpty) {
                              walletAmountStr = state.walletResponse!.balance!;
                            }

                            double walletAmount;
                            try {
                              walletAmount = double.parse(walletAmountStr);
                            } catch (_) {
                              walletAmount = 0.0;
                            }

                            return MyAppShimmer(
                              isLoading: state is GetWalletAmountLoading,
                              child: MyAppText(
                                data: _formatCurrency(walletAmount),
                                color: Colors.white,
                                size: 28.sp,
                                weight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        Spacer(),
                        _buildAddMoneyButton(),
                      ],
                    ),
                    // SizedBox(height: 10.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoneyButton() {
    return SizedBox(
      width: 120.w,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddMoneyBottomSheet();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 14.r,
                color: AppColors.brandPrimary,
              ),
            ),
            SizedBox(width: 12.w),
            MyAppText(
              data: 'Add Money',
              size: 12.sp,
              weight: FontWeight.w600,
              color: AppColors.brandPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      child: Row(
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        showLeading: false,
        centerTitle: false,
        title: MyAppText(
          data: 'My Wallet',
          size: 20.sp,
          weight: FontWeight.bold,
        ),
        actions: [CartIconButton()],
      ),
      body: context.read<StorageCubit>().isGuestMode == false
          ? RefreshIndicator(
              onRefresh: () async {
                _loadWalletData();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.brandPrimary,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildWalletCard(),
                    _buildSectionHeader(),
                    _buildTransactionList(),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            )
          : buildMsgState(
              context,
              'Sign in Required',
              'Please sign in to access your wallet and view transactions',
              () => context.push('/login', extra: {
                'guestMode': true,
              }),
              'Sign In',
              Iconsax.lock_outline,
            ),
    );
  }

  Widget _buildTransactionList() {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {},
      buildWhen: (previous, current) {
        return current is GetWalletTransactionsLoading ||
            current is GetWalletTransactionsSuccess ||
            current is GetWalletTransactionsError;
      },
      builder: (context, state) {
        if (state is GetWalletTransactionsLoading) {
          return _buildTransactionShimmer();
        } else if (state is GetWalletTransactionsError) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            child: buildMsgState(
              context,
              'Failed to Load',
              'Unable to load transaction history. Please try again.',
              () => _loadWalletData(),
              'Retry',
              Icons.error_outline_rounded,
            ),
          );
        }

        final transactionsData = state is GetWalletTransactionsSuccess
            ? state.transactionsData
            : context.read<WalletCubit>().cachedTransactions;

        if (transactionsData == null) {
          return _buildTransactionShimmer();
        }

        if (transactionsData.isEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 70.h),
            child: buildMsgState(
              context,
              'No Transactions Yet',
              'Your transaction history will appear here once you start using your wallet',
              () => _showAddMoneyBottomSheet(),
              'Add Money',
              Icons.receipt_long_rounded,
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactionsData.length,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final tx = transactionsData[index];
            return _buildTransactionItem(tx, index);
          },
        );
      },
    );
  }

  Widget _buildTransactionShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: MyAppShimmer(
            isLoading: true,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Colors.grey.shade300,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 10.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  height: 14.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      GetWalletTransactionsResponseModel tx, int index) {
    final bool isCredit = tx.transactionType1 == 'credit';

    return AnimatedContainer(
      duration: Duration(milliseconds: 100 + (index * 50)),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _showTransactionDetailsDialog(tx);
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isCredit
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green.shade600 : Colors.red.shade500,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppText(
                      data: tx.paymentMethod != ''
                          ? tx.paymentMethod ?? "Transaction"
                          : 'Transaction',
                      size: 12.sp,
                      weight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    MyAppText(
                      data: _formatDate(tx.date!),
                      size: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyAppText(
                    data:
                        '${isCredit ? '+' : '-'} ${_formatCurrency(double.parse(tx.amount!))}',
                    size: 13.sp,
                    weight: FontWeight.bold,
                    color:
                        isCredit ? Colors.green.shade600 : Colors.red.shade500,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      isCredit ? 'Credit' : 'Debit',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: isCredit
                            ? Colors.green.shade600
                            : Colors.red.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMoneyBottomSheet() {
    final walletScreenContext = context;
    final TextEditingController amountController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    PaymentGateway? selectedGateway = defaultPaymentGateway;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            top: 8.h,
            left: 24.w,
            right: 24.w,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Iconsax.wallet_add_1_bold,
                        color: AppColors.brandPrimary,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    MyAppText(
                      data: 'Add Money to Wallet',
                      size: 14.sp,
                      weight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 24.r,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                MyAppTextField(
                  prefixText: '₹',
                  hintText: "Enter amount to add",
                  controller: amountController,
                ),
                SizedBox(height: 16.h),
                MyAppText(
                  data: 'Quick amounts',
                  size: 14.sp,
                  weight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildAmountButton(100, amountController),
                    SizedBox(width: 8.w),
                    _buildAmountButton(200, amountController),
                    SizedBox(width: 8.w),
                    _buildAmountButton(500, amountController),
                    SizedBox(width: 8.w),
                    _buildAmountButton(1000, amountController),
                  ],
                ),
                // SizedBox(height: 8.h),
                // MyAppText(
                //   data: 'Pay Online',
                //   size: 12.sp,
                //   weight: FontWeight.w500,
                //   color: Colors.grey.shade600,
                // ),
                // StatefulBuilder(
                //   builder: (context, setSheetState) => PaymentGatewaySelector(
                //     selected: selectedGateway,
                //     onChanged: (gateway) =>
                //         setSheetState(() => selectedGateway = gateway),
                //   ),
                // ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: BlocConsumer<StorageCubit, StorageState>(
                    listener: (context, state) {},
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      GetAddressResponse? addressData;
                      try {
                        addressData = state.addressData
                            .where((item) => item.isPrimary == 1)
                            .first;
                      } catch (e) {
                        addressData = null;
                      }

                      return MyAppButton(
                        onPressed: addressData == null
                            ? () => context.push('/location-selection')
                            : () {
                                final amount = amountController.text.trim();
                                if (amount.isEmpty ||
                                    double.tryParse(amount) == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Please enter a valid amount'),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                  return;
                                }

                                Navigator.pop(context);
                                startOnlinePayment(
                                  walletScreenContext,
                                  gateway: selectedGateway,
                                  walletRequestDetails: addressData,
                                  isSubscription: false,
                                  isWallet: true,
                                  subScriptionAmount: double.parse(amount),
                                );
                              },
                        label: addressData == null
                            ? "Select Delivery Address"
                            : "Proceed to Payment",
                        icon: addressData == null
                            ? Iconsax.location_outline
                            : Iconsax.wallet_1_outline,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetailsDialog(
      GetWalletTransactionsResponseModel transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: transaction.transactionType1 == 'credit'
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  transaction.transactionType1 == 'credit'
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: transaction.transactionType1 == 'credit'
                      ? Colors.green.shade600
                      : Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _formatCurrency(double.parse(transaction.amount!)),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: transaction.transactionType1 == 'credit'
                      ? Colors.green.shade600
                      : Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 6),
              _buildDetailRow('Transaction ID', transaction.id!),
              const SizedBox(height: 12),
              _buildDetailRow('Date & Time', _formatDate(transaction.date!)),
              if (transaction.paymentMethod != "") const SizedBox(height: 12),
              if (transaction.paymentMethod != "")
                _buildDetailRow('Description', transaction.paymentMethod!),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Transaction Type',
                  transaction.transactionType1 == 'credit'
                      ? 'Money Added'
                      : 'Money Spent'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}


