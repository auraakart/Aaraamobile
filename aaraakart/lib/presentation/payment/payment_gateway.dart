import 'package:aaraa_kart/app/router/app_routes.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/data/model/create_subscription_request.dart';
import 'package:aaraa_kart/data/model/create_subscription_response.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/order_create_request.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/payment/paytm_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

enum PaymentGateway { paytm, ccavenue }

extension PaymentGatewayInfo on PaymentGateway {
  String get gatewayId => this == PaymentGateway.paytm ? 'paytm' : 'ccavenue';

  String get title => this == PaymentGateway.paytm ? 'Paytm' : 'CCAvenue';

  String get subtitle => this == PaymentGateway.paytm
      ? 'UPI, Wallet, Cards, Net Banking'
      : 'Cards, Net Banking, UPI';

  /// The gateway's own mark where the icon pack carries one - a Paytm logo is
  /// recognised faster than a generic wallet glyph.
  ///
  /// [color] flattens the mark to a single colour; pass null to let it keep the
  /// gateway's own colours.
  Widget logo({required double size, Color? color}) {
    switch (this) {
      case PaymentGateway.paytm:
        return Brand(
          Brands.paytm,
          size: size,
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      case PaymentGateway.ccavenue:
        // No CCAvenue mark in the pack, so a card glyph stands in for it.
        return Icon(
          Iconsax.card_bold,
          size: size,
          color: color ?? AppColors.brandPrimary,
        );
    }
  }

  bool get isConfigured {
    final payment = BrandConfig.instance.payment;
    switch (this) {
      case PaymentGateway.paytm:
        return payment.paytmMid.isNotEmpty &&
            payment.paytmInitiateTransactionUrl.isNotEmpty;
      case PaymentGateway.ccavenue:
        return payment.merchantId.isNotEmpty && payment.baseUrl.isNotEmpty;
    }
  }
}

List<PaymentGateway> get configuredPaymentGateways =>
    PaymentGateway.values.where((gateway) => gateway.isConfigured).toList();

PaymentGateway? get defaultPaymentGateway {
  // Prefer Paytm when available.
  if (PaymentGateway.paytm.isConfigured) {
    return PaymentGateway.paytm;
  }

  if (PaymentGateway.ccavenue.isConfigured) {
    return PaymentGateway.ccavenue;
  }

  return null;
}

void startOnlinePayment(
  BuildContext context, {
  PaymentGateway? gateway,
  OrderCreateRequest? orderRequestDetails,
  OrderCreateProducts? orderResponseDetails,
  CreateSubscriptionRequestModel? subRequestDetails,
  double? subScriptionAmount,
  String? subOrderID,
  CreateSubscriptionResponseModel? subResponseDetails,
  required bool isSubscription,
  required bool isWallet,
  GetAddressResponse? walletRequestDetails,
}) {
  // Use selected gateway if provided, otherwise fallback.
  final PaymentGateway selected = gateway ?? PaymentGateway.paytm;

  // Validate payment gateway configuration.
  if (!selected.isConfigured) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selected.title} is not configured.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }

  // Validate Order / Subscription details before payment.
  // Validate normal order payment.
// Wallet payments do not require orderResponseDetails.
  if (!isSubscription && !isWallet && orderResponseDetails == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order was not created. Please try again."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }
  if (isSubscription && (subOrderID == null || subOrderID.isEmpty)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subscription was not created. Please try again."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }

  switch (selected) {
    case PaymentGateway.paytm:
      startPaytmPayment(
        context,
        orderRequestDetails: orderRequestDetails,
        orderResponseDetails: orderResponseDetails,
        subRequestDetails: subRequestDetails,
        subScriptionAmount: subScriptionAmount,
        subOrderID: subOrderID,
        subResponseDetails: subResponseDetails,
        isSubscription: isSubscription,
        isWallet: isWallet,
        walletRequestDetails: walletRequestDetails,
      );
      break;

    case PaymentGateway.ccavenue:
      context.pushNamed(
        AppRoutes.payment.name,
        extra: {
          "orderRequestDetails": orderRequestDetails,
          "orderResponseDetails": orderResponseDetails,
          "subRequestDetails": subRequestDetails,
          "subScriptionAmount": subScriptionAmount,
          "subOrderID": subOrderID,
          "subResponseDetails": subResponseDetails,
          "isSubscription": isSubscription,
          "isWallet": isWallet,
          "walletRequestDetails": walletRequestDetails,
        },
      );
      break;
  }
}

void showPaymentCancelledSnackBar(BuildContext context) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text("Payment cancelled"),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
}

class PaymentGatewaySelector extends StatelessWidget {
  final PaymentGateway? selected;
  final ValueChanged<PaymentGateway> onChanged;

  final String? label;

  const PaymentGatewaySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.label = 'Pay using',
  });

  @override
  Widget build(BuildContext context) {
    final gateways = configuredPaymentGateways;
    if (gateways.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          SizedBox(height: 12.h),
          // Row(
          //   children: [
          //     Icon(
          //       Iconsax.security_safe_bold,
          //       color: AppColors.brandPrimary,
          //       size: 14.r,
          //     ),
          //     SizedBox(width: 8.w),
          //     MyAppText(
          //       data: label!,
          //       size: 11.sp,
          //       weight: FontWeight.w600,
          //       color: AppColors.textSecondary,
          //     ),
          //   ],
          // ),
        ],
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: gateways.map(_buildGatewayChip).toList(),
        ),
      ],
    );
  }

  Widget _buildGatewayChip(PaymentGateway gateway) {
    final bool isSelected = selected == gateway;

    return GestureDetector(
      onTap: () => onChanged(gateway),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            gateway.logo(size: 14.r, color: isSelected ? Colors.white : null),
            SizedBox(width: 8.w),
            MyAppText(
              data: gateway.title,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              weight: isSelected ? FontWeight.bold : FontWeight.w500,
              size: 12.sp,
            ),
          ],
        ),
      ),
    );
  }
}
