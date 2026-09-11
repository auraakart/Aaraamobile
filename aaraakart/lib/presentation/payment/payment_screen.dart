import 'dart:async';
import 'dart:convert';

import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_state.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_cubit.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_state.dart';
import 'package:aaraa_kart/data/model/create_subscription_request.dart';
import 'package:aaraa_kart/data/model/create_subscription_response.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/order_create_request.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:aaraa_kart/data/model/order_success_route_model.dart';
import 'package:aaraa_kart/data/model/update_order_request.dart';
import 'package:aaraa_kart/data/model/update_subscription_request.dart';
import 'package:aaraa_kart/presentation/common/my_app_dialog.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/payment/checkout_webview.dart';
import 'package:aaraa_kart/presentation/payment/payment_gateway.dart';
import 'package:aaraa_kart/presentation/payment/upi_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final OrderCreateRequest? orderRequestDetails;
  final OrderCreateProducts? orderResponseDetails;
  final CreateSubscriptionRequestModel? subRequestDetails;
  final double? subScriptionAmount;
  final String? subOrderID;
  final CreateSubscriptionResponseModel? subResponseDetails;
  final bool isSubscription;
  final bool isWallet;
  final GetAddressResponse? walletRequestDetails;

  const PaymentScreen(
      {super.key,
      required this.orderRequestDetails,
      this.subRequestDetails,
      required this.isSubscription,
      required this.orderResponseDetails,
      this.subScriptionAmount,
      required this.isWallet,
      this.walletRequestDetails,
      this.subOrderID,
      this.subResponseDetails});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _webViewLoading = true;
  bool _processingPayment = false;
  bool _paymentProcessed = false;
  bool _paymentCancelled = false;
  bool _cancellationCompleted = false;
  late InAppWebViewController _webViewController;
  Timer? _processingTimeout;

  /// The checkout page is only mounted once the user-agent has been resolved -
  /// it cannot be swapped after the webview is created, and the gateway decides
  /// which payment options to render off the very first request.
  bool _userAgentReady = false;
  String? _userAgent;

  String orderId = "";
  final merchantId = BrandConfig.instance.payment.merchantId;
  final language = "EN";
  String amount = "";
  final currency = "INR";
  String redirectUrl = "";
  String cancelUrl = "";
  String billingName = "";
  String billingAddress = "";
  String billingState = "";
  String billingZip = "";
  String billingCountry = "";
  String billingTel = "";
  String billingEmail = "";
  String billingCity = "";

  @override
  void initState() {
    super.initState();
    _initializePaymentData();
    _resolveUserAgent();
  }

  @override
  void dispose() {
    _processingTimeout?.cancel();
    super.dispose();
  }

  Future<void> _resolveUserAgent() async {
    final userAgent = await resolveCheckoutUserAgent();

    if (!mounted) return;

    setState(() {
      _userAgent = userAgent;
      _userAgentReady = true;
    });
  }

  double getTotalAmount() {
    final cartItems = context
        .read<CartCubit>()
        .state
        .items
        .where((item) => !item.isOutOfStock);

    double total = 0.0;

    for (var item in cartItems) {
      final price = double.tryParse(item.price.toString()) ?? 0.0;

      total += price * item.quantity;
    }

    return total;
  }

  void _initializePaymentData() {
    if (widget.isWallet) {
      final String epoch = DateTime.now().millisecondsSinceEpoch.toString();
      final String shortEpoch = epoch.substring(epoch.length - 8);
      orderId =
          'WAL_${widget.walletRequestDetails?.customerId ?? "0"}_$shortEpoch';
      amount = widget.subScriptionAmount?.toString() ?? "0";
      billingName = context.read<StorageCubit>().userData!.name ??
          widget.walletRequestDetails?.name ??
          "Wallet User";
      billingAddress =
          "${widget.walletRequestDetails?.address1 ?? ''} - ${widget.walletRequestDetails?.address2 ?? ''}";
      billingZip = widget.walletRequestDetails?.postcode ?? "";
      billingState = widget.walletRequestDetails?.state ?? "";
      billingCountry = "India";
      billingEmail = context.read<StorageCubit>().userData!.email ?? "";
      billingTel = context.read<StorageCubit>().userData!.phoneNumber ?? '';
      billingCity = widget.walletRequestDetails?.city ?? "";
    } else if (widget.isSubscription) {
      orderId = widget.subOrderID?.toString() ?? '';
      amount = widget.subScriptionAmount.toString();

      final billing = widget.subRequestDetails!.billing!;
      billingName = billing.firstName ?? '';
      billingAddress = "${billing.address2 ?? ''} - ${billing.address1 ?? ''}";
      billingZip = billing.postcode ?? '';
      billingState = billing.state ?? '';
      billingCountry = "India";
      billingEmail = billing.email ?? '';
      billingTel = billing.phone ?? '';
      billingCity = billing.city ?? '';
    } else {
      orderId = widget.orderResponseDetails!.id.toString();
      amount = getTotalAmount().toString() ??
          widget.orderResponseDetails!.total.toString();

      final billing = widget.orderResponseDetails!.billing!;
      billingName = billing.firstName ?? '';
      billingAddress = "${billing.address2 ?? ''} - ${billing.address1 ?? ''}";
      billingZip = billing.postcode ?? '';
      billingState = billing.state ?? '';
      billingCountry = "India";
      billingEmail = billing.email ?? '';
      billingTel = billing.phone ?? '';
      billingCity = billing.city ?? '';
    }

    redirectUrl = "${BrandConfig.instance.payment.responseUrl}?oid=$orderId";
    cancelUrl = "${BrandConfig.instance.payment.cancelUrl}?oid=$orderId";
  }

  Future<bool> _onWillPop() async {
    if (_processingPayment) {
      _showProcessingDialog();
      return false;
    }

    return (await showDialog(
          context: context,
          builder: (context) => MyAppDialog(
            title: "Alert",
            subtitle: "Do you want to cancel this transaction?",
            positiveText: "Yes",
            negativeText: "Cancel",
            onPositivePressed: () {
              _handleTransactionCancellation();
            },
            onNegativePressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        )) ??
        false;
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Processing payment, please wait..."),
          ],
        ),
      ),
    );
  }

  void _handleTransactionCancellation() {
    // Close the confirmation dialog only - the screen itself is popped once the
    // cancellation has been pushed to the server.
    Navigator.of(context).pop(false);

    _handlePaymentStatus(
        widget.isSubscription
            ? SubscriptionStatus.cancelled
            : OrderStatus.cancelled,
        cancelled: true);
  }

  void _handlePaymentStatus(String status, {bool cancelled = false}) {
    if (_paymentProcessed) {
      return;
    }

    setState(() {
      _processingPayment = true;
      _paymentProcessed = true;
      _paymentCancelled = cancelled;
    });

    _processingTimeout?.cancel();

    if (cancelled) {
      // Never trap the shopper behind the spinner when the status update stalls
      // - the transaction is already over at this point.
      _processingTimeout = Timer(const Duration(seconds: 10), () {
        if (mounted) _finishCancelled();
      });
    }

    if (widget.isWallet) {
      final customerId = widget.walletRequestDetails?.customerId?.toString() ??
          context.read<StorageCubit>().userData?.customerID;
      if (status == "success") {
        BlocProvider.of<WalletCubit>(context).updateWalletAmount(
            customerId, widget.subScriptionAmount);
      } else {
        BlocProvider.of<WalletCubit>(context)
            .updateWalletAmount(customerId, '0');
      }
    } else {
      if (widget.isSubscription) {
        final subscriptionId =
            widget.subResponseDetails?.subscriptionId?.toString();
        if (subscriptionId != null && subscriptionId.isNotEmpty) {
          BlocProvider.of<SubscriptionsCubit>(context).updateSubscription(
              UpdateSubscriptionRequest(status: status),
              subscriptionId);
        }

        final dynamicOrderId = widget.subOrderID ??
            widget.subResponseDetails?.orderId?.toString();
        if (dynamicOrderId != null && dynamicOrderId.isNotEmpty) {
          final orderStatus = (status == SubscriptionStatus.active || status == 'active')
              ? OrderStatus.processing
              : (cancelled || status == SubscriptionStatus.cancelled || status == 'cancelled'
                  ? OrderStatus.cancelled
                  : (status == SubscriptionStatus.pending || status == 'pending'
                      ? OrderStatus.pendingPayment
                      : OrderStatus.failed));
          BlocProvider.of<OrderCubit>(context).updateOrder(
              UpdateOrderReqest(status: orderStatus),
              dynamicOrderId);
        }
      } else {
        BlocProvider.of<OrderCubit>(context).updateOrder(
            UpdateOrderReqest(status: status),
            widget.orderResponseDetails!.id.toString());
      }
    }
  }

  /// A cancelled/aborted transaction is not an order failure: the status update
  /// still goes out, but the shopper only gets a snackbar and is handed back to
  /// the screen the payment was started from.
  void _finishCancelled() {
    if (_cancellationCompleted) return;
    _cancellationCompleted = true;

    _processingTimeout?.cancel();

    setState(() {
      _processingPayment = false;
    });

    showPaymentCancelledSnackBar(context);

    if (context.canPop()) {
      context.pop();
    } else {
      context.pushReplacement("/bottom-bar");
    }
  }

  void _navigateToResult(bool isSuccess,
      {OrderCreateResponseModel? orderResponse, String? errorMessage}) {
    setState(() {
      _processingPayment = false;
    });

    if (isSuccess) {
      if (widget.isSubscription) {
        context.pushReplacement("/order-success", extra: {
          "orderDetails": OrderSuccessRouteModel(
              deliveryInfo:
                  widget.subRequestDetails!.billing!.customerNote ?? '',
              orderDate:
                  DateFormat('MMM d, yyyy • hh:mm a').format(DateTime.now()),
              orderId: widget.subOrderID!,
              subscriptionId:
                  widget.subResponseDetails?.subscriptionId.toString(),
              deliverySlot: widget.subResponseDetails?.deliverySlot,
              deliverySchedule: widget.subResponseDetails?.deliverySchedule,
              deliveryDays: widget.subResponseDetails?.deliveryDays,
              paymentMethod: "Online Payment",
              totalAmount: widget.subScriptionAmount.toString()),
          "isSubscription": true
        });
      } else {
        context.pushReplacement("/order-success", extra: {
          "orderDetails": OrderSuccessRouteModel(
              deliveryInfo:
                  widget.orderRequestDetails!.billing!.customerNote ?? '',
              orderDate: DateFormat('MMM d, yyyy • hh:mm a').format(
                orderResponse?.products!.dateCompleted ?? DateTime.now(),
              ),
              orderId: orderResponse!.products!.id.toString(),
              paymentMethod: orderResponse.products!.paymentMethodTitle ??
                  'Online Payment',
              totalAmount: getTotalAmount().toString() ??
                  orderResponse.total.toString()),
          "isSubscription": false
        });
        context.read<CartCubit>().clearCart();
      }
    } else {
      context.pushReplacement("/order-failed", extra: {
        "errorMessage": errorMessage,
        "transactionId": orderId.isNotEmpty ? orderId : null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: MyAppText(data: 'Payment'),
          centerTitle: false,
          automaticallyImplyLeading: !_processingPayment,
        ),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<SubscriptionsCubit, SubscriptionState>(
                listener: (context, state) {
                  if (_paymentCancelled) {
                    if (state is SubscriptionUpdateSuccess ||
                        state is SubscriptionUpdateError) {
                      _finishCancelled();
                    }
                    return;
                  }

                  if (state is SubscriptionUpdateLoading) {
                  } else if (state is SubscriptionUpdateSuccess) {
                    try {
                      if (state.subscriptionResponse?.status == "active") {
                        _navigateToResult(true,
                            orderResponse: state.subscriptionResponse);
                      } else {
                        _navigateToResult(false,
                            errorMessage:
                                'Your subscription could not be activated (status: ${state.subscriptionResponse?.status ?? 'unknown'}). If the amount was deducted, it will be refunded shortly.');
                      }
                    } catch (e) {
                      _navigateToResult(false, errorMessage: e.toString());
                    }
                  } else if (state is SubscriptionUpdateError) {
                    _navigateToResult(false, errorMessage: state.message);
                  }
                },
              ),
              BlocListener<OrderCubit, OrderState>(
                listener: (context, state) {
                  if (_paymentCancelled) {
                    if (state is OrderUpdateSuccess ||
                        state is OrderUpdateError) {
                      _finishCancelled();
                    }
                    return;
                  }

                  if (widget.isSubscription) {
                    // For subscription orders, navigation and UI results are driven by SubscriptionsCubit
                    return;
                  }

                  if (state is OrderUpdateLoading) {
                  } else if (state is OrderUpdateSuccess) {
                    if (state.orderResponse!.products!.status == "processing") {
                      _navigateToResult(true,
                          orderResponse: state.orderResponse);
                    } else {
                      _navigateToResult(false,
                          errorMessage:
                              'Your order could not be completed (status: ${state.orderResponse!.products!.status ?? 'unknown'}). If the amount was deducted, it will be refunded shortly.');
                    }
                  } else if (state is OrderUpdateError) {
                    _navigateToResult(false, errorMessage: state.message);
                  }
                },
              ),
              BlocListener<WalletCubit, WalletState>(
                  listener: (context, state) {
                if (_paymentCancelled) {
                  if (state is UpdateWalletAmountSuccess ||
                      state is UpdateWalletAmountError) {
                    _finishCancelled();
                  }
                  return;
                }

                if (state is UpdateWalletAmountLoading) {
                } else if (state is UpdateWalletAmountSuccess) {
                  final customerId = widget.walletRequestDetails?.customerId?.toString() ??
                      context.read<StorageCubit>().userData?.customerID;
                  if (customerId != null && customerId.isNotEmpty) {
                    final walletCubit = BlocProvider.of<WalletCubit>(context);
                    walletCubit.getWalletAmount(customerId);
                    walletCubit.getWalletTransactions(customerId);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MyAppText(
                                  data: 'Payment Successful!',
                                  color: Colors.white,
                                  weight: FontWeight.w600,
                                  size: 14.sp,
                                ),
                                SizedBox(height: 2),
                                MyAppText(
                                  data: 'Wallet balance updated successfully',
                                  color: Colors.white.withOpacity(0.9),
                                  size: 12.sp,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      margin: EdgeInsets.all(16.w),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      context.pushReplacement(
                        "/wallet",
                      );
                    }
                  });
                } else if (state is UpdateWalletAmountError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MyAppText(
                                  data: 'Payment Failed!',
                                  color: Colors.white,
                                  weight: FontWeight.w600,
                                  size: 14.sp,
                                ),
                                SizedBox(height: 2),
                                MyAppText(
                                  data: 'Unable to update wallet balance',
                                  color: Colors.white.withOpacity(0.9),
                                  size: 12.sp,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      margin: EdgeInsets.all(16.w),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      context.pushReplacement("/bottom-bar");
                    }
                  });
                }
              }),
            ],
            child: Stack(
              children: [
                if (_userAgentReady)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: InAppWebView(
                        initialOptions:
                            buildCheckoutWebViewOptions(userAgent: _userAgent),
                        initialData: InAppWebViewInitialData(data: _loadHTML()),
                        onWebViewCreated: (InAppWebViewController controller) {
                          _webViewController = controller;
                        },
                        onLoadError: (controller, url, code, message) {
                          print("WebView Load Error: $message");
                          if (mounted) {
                            setState(() {
                              _webViewLoading = false;
                            });
                          }
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          final uri = navigationAction.request.url;
                          print("Navigation URI: $uri");

                          if (uri == null) return NavigationActionPolicy.ALLOW;

                          return handleUpiIntentNavigation(
                              context, controller, uri);
                        },
                        onLoadStop: (InAppWebViewController controller,
                            Uri? pageUri) async {
                          if (mounted) {
                            setState(() {
                              _webViewLoading = false;
                            });
                          }

                          final page = pageUri?.toString() ?? '';
                          print("Loaded Page URI: $page");

                          if (page.contains("payment_response.php") ||
                              page.contains("payment_cancel.php")) {
                            await _processPaymentResponse(controller);
                          }
                        }),
                  ),
                if (_webViewLoading || _processingPayment)
                  Container(
                    color: Colors.white.withOpacity(1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            _processingPayment
                                ? "Processing payment..."
                                : "Loading payment gateway...",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPaymentResponse(
      InAppWebViewController controller) async {
    if (_paymentProcessed) {
      print("✅ Payment already processed - skipping.");
      return;
    }

    try {
      setState(() {
        _processingPayment = true;
      });

      _processingTimeout?.cancel();
      _processingTimeout = Timer(const Duration(seconds: 7), () {
        if (!_paymentProcessed && mounted) {
          print("⛔ Processing timeout reached — marking as pending");
          _handlePaymentStatus(widget.isSubscription
              ? SubscriptionStatus.pending
              : OrderStatus.pendingPayment);
        }
      });

      final rawBodyDynamic = await controller.evaluateJavascript(
        source: "document.body ? document.body.innerText : '';",
      );

      final rawBody = (rawBodyDynamic ?? '').toString().trim();
      print("🔎 Body text from page: $rawBody");

      String statusFromServer = '';

      if (rawBody.isNotEmpty) {
        final parsed = parseCcavenaveBodyFlexible(rawBody);
        print("🧾 Parsed body map: $parsed");

        statusFromServer = (parsed['order_status'] ?? '').toLowerCase();
      } else {
        // Fallback: try to read URL params
        try {
          final currentUrl = await controller.getUrl();
          final uri = Uri.parse(currentUrl.toString());
          final statusFromQuery =
              (uri.queryParameters['status'] ?? '').toLowerCase();
          final oidFromQuery = uri.queryParameters['oid'] ?? '';
          if (statusFromQuery.isNotEmpty) {
            statusFromServer = statusFromQuery;
            print(
                "🔎 Found status from query params: $statusFromQuery oid:$oidFromQuery");
          } else {
            print("⚠ No body and no status query param found.");
          }
        } catch (e) {
          print("⚠ Error while parsing fallback URL: $e");
        }
      }

      if (statusFromServer.isEmpty) {
        print("⚠ Status unknown -> pending");
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.pending
            : OrderStatus.pendingPayment);
        return;
      }

      // CCAvenue reports a shopper who backed out of the gateway as "Aborted".
      final bool isCancelled = statusFromServer.contains("aborted") ||
          statusFromServer.contains("cancel");

      if (widget.isWallet) {
        if (statusFromServer.contains("success")) {
          _handlePaymentStatus('success');
        } else if (statusFromServer.contains("failure")) {
          _handlePaymentStatus('failed');
        } else if (isCancelled) {
          _handlePaymentStatus('cancelled', cancelled: true);
        }
        return;
      }

      if (statusFromServer.contains("success")) {
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.active
            : OrderStatus.processing);
      } else if (statusFromServer.contains("failure")) {
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.cancelled
            : OrderStatus.failed);
      } else if (isCancelled) {
        _handlePaymentStatus(
            widget.isSubscription
                ? SubscriptionStatus.cancelled
                : OrderStatus.cancelled,
            cancelled: true);
      } else {
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.pending
            : OrderStatus.pendingPayment);
      }
    } catch (e) {
      print("❌ Error processing payment response: $e");
      _handlePaymentStatus(widget.isSubscription
          ? SubscriptionStatus.pending
          : OrderStatus.pendingPayment);
    }
  }

  String _loadHTML() {
    String html = """
  <html>
    <head>
      <meta name='viewport' content='width=device-width, initial-scale=1.0'>
      <style>
        body { 
          font-family: Arial, sans-serif; 
          padding: 20px; 
          text-align: center; 
        }
        .loading { 
          margin: 50px 0; 
        }
      </style>
    </head>
    <body onload='document.f.submit();'>
      <div class="loading">
        <p>Redirecting to payment gateway...</p>
        <p>Please wait...</p>
      </div>
      <form id='f' name='f' method='post' action='${BrandConfig.instance.payment.requestHandlerUrl}'>
        <input type="hidden" name="order_id" value="$orderId">
        <input type="hidden" name="merchant_id" value="$merchantId">
        <input type="hidden" name="language" value="$language">
        <input type="hidden" name="amount" value="$amount">
        <input type="hidden" name="currency" value="$currency">
        <input type="hidden" name="redirect_url" value="$redirectUrl">
        <input type="hidden" name="cancel_url" value="$cancelUrl">
        <input type="hidden" name="billing_name" value="$billingName">
        <input type="hidden" name="billing_address" value="$billingAddress">
        <input type="hidden" name="billing_state" value="$billingState">
        <input type="hidden" name="billing_zip" value="$billingZip">
        <input type="hidden" name="billing_country" value="$billingCountry">
        <input type="hidden" name="billing_city" value="$billingCity">
        <input type="hidden" name="billing_tel" value="$billingTel">
        <input type="hidden" name="billing_email" value="$billingEmail">
      </form>
    </body>
  </html>
  """;

    return html;
  }
}

Map<String, String> parseCcavenaveBodyFlexible(String input) {
  final Map<String, String> result = {};

  final normalized = input.replaceAll("'", '"');

  final regex = RegExp(r'\[\s*"([^"]+)"\s*,\s*"([^"]*)"\s*\]');

  for (final match in regex.allMatches(normalized)) {
    final key = match.group(1)?.trim();
    final value = match.group(2)?.trim();
    if (key != null && key.isNotEmpty) {
      result[key] = value ?? '';
    }
  }

  if (result.isEmpty && input.contains('=')) {
    try {
      final parts = input.split(RegExp(r'&|\n'));
      for (final p in parts) {
        if (p.contains('=')) {
          final kv = p.split('=');
          if (kv.length >= 2) {
            result[kv[0].trim()] = Uri.decodeComponent(kv.sublist(1).join('='));
          }
        }
      }
    } catch (_) {}
  }

  if (result.isEmpty) {
    final jsonLike = input.trim();
    try {
      if (jsonLike.startsWith('{') && jsonLike.endsWith('}')) {
        final map = json.decode(jsonLike);
        if (map is Map) {
          map.forEach((k, v) {
            result[k.toString()] = v?.toString() ?? '';
          });
        }
      }
    } catch (_) {
      // ignore
    }
  }

  return result;
}
