import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';
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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Paytm hosted checkout rendered inside an in-app webview.
///
/// Same process as the CCAvenue [PaymentScreen]: post an auto-submitting form
/// to the gateway, watch the webview for the merchant/gateway callback page and
/// translate the response into an order, subscription or wallet update. The
/// difference is that Paytm needs a `txnToken` from the merchant server before
/// the form can be posted, so the checkout is prepared in [initState].
class PaytmWebviewScreen extends StatefulWidget {
  final OrderCreateRequest? orderRequestDetails;
  final OrderCreateProducts? orderResponseDetails;
  final CreateSubscriptionRequestModel? subRequestDetails;
  final double? subScriptionAmount;
  final String? subOrderID;
  final CreateSubscriptionResponseModel? subResponseDetails;
  final bool isSubscription;
  final bool isWallet;
  final GetAddressResponse? walletRequestDetails;

  const PaytmWebviewScreen(
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
  State<PaytmWebviewScreen> createState() => _PaytmWebviewScreenState();
}

class _PaytmWebviewScreenState extends State<PaytmWebviewScreen>
    with WidgetsBindingObserver {
  bool _webViewLoading = true;
  bool _preparingCheckout = true;
  bool _processingPayment = false;
  bool _paymentProcessed = false;
  bool _paymentCancelled = false;
  bool _cancellationCompleted = false;
  bool _externalAppLaunched = false;
  Timer? _processingTimeout;

  String orderId = "";
  String amount = "";
  String? _txnToken;
  String? _prepareError;

  bool _userAgentReady = false;
  String? _userAgent;
  late InAppWebViewController _webViewController;
  final _mid = BrandConfig.instance.payment.paytmMid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePaymentData();
    _prepareCheckout();
    _resolveUserAgent();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _externalAppLaunched &&
        !_paymentProcessed) {
      _verifyTransactionStatusWithBackend();
    }
  }

  Future<void> _resolveUserAgent() async {
    final userAgent = await resolveCheckoutUserAgent();

    if (!mounted) return;

    setState(() {
      _userAgent = userAgent;
      _userAgentReady = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _processingTimeout?.cancel();
    super.dispose();
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
      amount = (widget.subScriptionAmount ?? 0).toStringAsFixed(2);
    } else if (widget.isSubscription) {
      orderId = widget.subOrderID?.toString() ?? '';
      amount = (widget.subScriptionAmount ?? 0).toStringAsFixed(2);
    } else {
      orderId = widget.orderResponseDetails!.id.toString();
      amount = getTotalAmount().toStringAsFixed(2);
    }
  }

  Future<void> _prepareCheckout() async {
    setState(() {
      _preparingCheckout = true;
      _prepareError = null;
    });

    final token = await _fetchTxnToken();

    if (!mounted) return;

    setState(() {
      _preparingCheckout = false;
      _txnToken = token;
      _prepareError = (token == null || token.isEmpty)
          ? 'Could not prepare the secure payment request.'
          : null;
    });
  }

  Future<String?> _fetchTxnToken() async {
    try {
      final response = await Dio().post<Map<String, dynamic>>(
        BrandConfig.instance.payment.paytmInitiateTransactionUrl,
        data: {
          'order_id': orderId,
          'amount': amount,
        },
      );

      final body = response.data?['body'];
      if (body is! Map) {
        debugPrint(
            'Paytm initiateTransaction: unexpected response ${response.data}');
        return null;
      }

      final resultInfo = body['resultInfo'];
      final resultStatus =
          resultInfo is Map ? resultInfo['resultStatus']?.toString() : null;
      if (resultStatus != 'S') {
        debugPrint(
            'Paytm initiateTransaction: not successful, resultInfo=$resultInfo');
        return null;
      }

      return body['txnToken']?.toString();
    } catch (e) {
      debugPrint('Paytm initiateTransaction call failed: $e');
      return null;
    }
  }

  // ============================================================
  // PAYTM IOS JS CHECKOUT BRIDGE & SIGNAL HANDLING
  // ============================================================

  void _setupIosJsBridge(InAppWebViewController controller) {
    if (!Platform.isIOS) return;

    debugPrint('[Paytm iOS UPI] Registering sendSignalToNative JS handler...');
    controller.addJavaScriptHandler(
      handlerName: 'sendSignalToNative',
      callback: (args) async {
        debugPrint('[Paytm iOS UPI] 📥 sendSignalToNative received args: $args');
        if (args.isEmpty) return;

        Map<String, dynamic>? data;
        final firstArg = args[0];
        if (firstArg is Map) {
          data = Map<String, dynamic>.from(firstArg);
        } else if (firstArg is String) {
          try {
            final decoded = jsonDecode(firstArg);
            if (decoded is Map) {
              data = Map<String, dynamic>.from(decoded);
            }
          } catch (e) {
            debugPrint('[Paytm iOS UPI] Error decoding JS message string: $e');
          }
        }

        final messageName = data?['message']?.toString() ??
            data?['action']?.toString() ??
            data?['signal']?.toString() ??
            '';

        debugPrint('[Paytm iOS UPI] 🔔 Parsed messageName: $messageName');

        if (messageName == 'Execute setUpiIntentApps' ||
            messageName.toLowerCase().contains('setupiintentapps')) {
          await _handleExecuteSetUpiIntentApps(controller);
        } else if (messageName == 'invokePSPApp' ||
            messageName.toLowerCase().contains('invokepspapp')) {
          final deeplink = data?['deeplink']?.toString() ??
              data?['deepLink']?.toString() ??
              data?['url']?.toString() ??
              '';
          await _handleInvokePspApp(deeplink);
        }
      },
    );
  }

  Future<void> _injectIosBridgeShim(InAppWebViewController controller) async {
    if (!Platform.isIOS) return;

    const shimScript = """
      (function() {
        if (!window.webkit) { window.webkit = {}; }
        if (!window.webkit.messageHandlers) { window.webkit.messageHandlers = {}; }
        if (!window.webkit.messageHandlers.sendSignalToNative) {
          window.webkit.messageHandlers.sendSignalToNative = {
            postMessage: function(msg) {
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler('sendSignalToNative', msg);
              }
            }
          };
          console.log('[Paytm iOS UPI Bridge] sendSignalToNative bridge initialized');
        }
      })();
    """;

    try {
      await controller.evaluateJavascript(source: shimScript);
      debugPrint('[Paytm iOS UPI] Injected sendSignalToNative JS shim');
    } catch (e) {
      debugPrint('[Paytm iOS UPI] Error injecting JS shim: $e');
    }
  }

  Future<void> _handleExecuteSetUpiIntentApps(
      InAppWebViewController controller) async {
    debugPrint('[Paytm iOS UPI] 🚀 Handling Execute setUpiIntentApps...');
    final List<Map<String, dynamic>> installedApps = [];

    // 1. Attempt to fetch PSP schemas from Paytm fetchPspApps API
    try {
      final gatewayBaseUrl = BrandConfig.instance.payment.paytmGatewayBaseUrl;
      final fetchPspUrl =
          '$gatewayBaseUrl/theia/api/v1/fetchPspApps?mid=$_mid&orderId=$orderId';
      debugPrint('[Paytm iOS UPI] 🌐 Fetching PSP apps from: $fetchPspUrl');

      final response = await Dio().post(
        fetchPspUrl,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
        data: {
          'head': {'txnToken': _txnToken ?? ''},
          'body': {'mid': _mid, 'orderId': orderId},
        },
      );

      debugPrint('[Paytm iOS UPI] 📦 fetchPspApps response: ${response.data}');

      final body = response.data?['body'];
      final pspSchemas = body is Map ? body['pspSchemas'] : null;

      if (pspSchemas is List && pspSchemas.isNotEmpty) {
        for (final psp in pspSchemas) {
          if (psp is Map) {
            final scheme = psp['scheme']?.toString() ?? '';
            if (scheme.isNotEmpty) {
              final uri = Uri.tryParse(scheme);
              if (uri != null && await canLaunchUrl(uri)) {
                debugPrint(
                    '[Paytm iOS UPI] ✅ Installed PSP: ${psp['displayName']} ($scheme)');
                installedApps.add(Map<String, dynamic>.from(psp));
              } else {
                debugPrint(
                    '[Paytm iOS UPI] ❌ Not installed: ${psp['displayName']} ($scheme)');
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[Paytm iOS UPI] ⚠️ fetchPspApps API error: $e');
    }

    // 2. Fallback: if API returned nothing or failed, query standard iOS UPI schemes
    if (installedApps.isEmpty) {
      debugPrint('[Paytm iOS UPI] 🔄 Running local fallback PSP detection...');
      final defaultPspList = [
        {
          'name': 'PAYTM',
          'displayName': 'Paytm',
          'scheme': 'paytmmp://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/paytm.png',
        },
        {
          'name': 'GPAY',
          'displayName': 'Google Pay',
          'scheme': 'gpay://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/gpay.png',
        },
        {
          'name': 'PHONEPE',
          'displayName': 'PhonePe',
          'scheme': 'phonepe://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/phonepe.png',
        },
        {
          'name': 'CRED',
          'displayName': 'Cred',
          'scheme': 'credpay://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/cred.png',
        },
        {
          'name': 'BHIM',
          'displayName': 'BHIM UPI',
          'scheme': 'bhim://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/bhim.png',
        },
        {
          'name': 'PAYZAPP',
          'displayName': 'PayZapp',
          'scheme': 'payzapp://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/payzapp.png',
        },
        {
          'name': 'MOBIKWIK',
          'displayName': 'MobiKwik',
          'scheme': 'mobikwik://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/mobikwik.png',
        },
        {
          'name': 'AMAZONPAY',
          'displayName': 'Amazon Pay',
          'scheme': 'amazonpay://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/amazonpay.png',
        },
        {
          'name': 'WHATSAPP',
          'displayName': 'WhatsApp',
          'scheme': 'whatsapp://',
          'icon':
              'https://staticpg.paytmpayments.com/pg-unified-assets/v1/upi/whatsapp.png',
        },
      ];

      for (final psp in defaultPspList) {
        final scheme = psp['scheme']?.toString() ?? '';
        if (scheme.isNotEmpty) {
          final uri = Uri.tryParse(scheme);
          if (uri != null && await canLaunchUrl(uri)) {
            debugPrint(
                '[Paytm iOS UPI] ✅ Local detection found: ${psp['displayName']} ($scheme)');
            installedApps.add(psp);
          }
        }
      }
    }

    final dataToSend = jsonEncode(installedApps);
    debugPrint(
        '[Paytm iOS UPI] 📤 Passing installed apps to WebView: $dataToSend');

    final jsCallback = """
      if (window.upiIntent && window.upiIntent.setUpiIntentApps) {
        window.upiIntent.setUpiIntentApps('$dataToSend');
      } else if (window.Paytm && window.Paytm.JSCheckout && window.Paytm.JSCheckout.setUpiIntentApps) {
        window.Paytm.JSCheckout.setUpiIntentApps('$dataToSend');
      }
    """;

    try {
      await controller.evaluateJavascript(source: jsCallback);
      debugPrint('[Paytm iOS UPI] ✅ setUpiIntentApps evaluated successfully');
    } catch (e) {
      debugPrint('[Paytm iOS UPI] ❌ Error executing setUpiIntentApps: $e');
    }
  }

  Future<void> _handleInvokePspApp(String deeplink) async {
    debugPrint('[Paytm iOS UPI] 📲 Invoking PSP App with deeplink: $deeplink');
    if (deeplink.isEmpty) {
      debugPrint('[Paytm iOS UPI] ⚠️ Deeplink is empty');
      return;
    }

    final uri = Uri.tryParse(deeplink);
    if (uri == null) {
      debugPrint('[Paytm iOS UPI] ❌ Invalid deeplink URI: $deeplink');
      return;
    }

    _externalAppLaunched = true;

    try {
      final launched = await launchUrl(
        uri,
        mode: Platform.isIOS
            ? LaunchMode.externalNonBrowserApplication
            : LaunchMode.externalApplication,
      );
      debugPrint('[Paytm iOS UPI] 🚀 UPI App launched result: $launched');
      if (!launched) {
        if (context.mounted) {
          showNoUpiAppSnackBar(context);
        }
      }
    } catch (e) {
      debugPrint('[Paytm iOS UPI] ❌ Error launching UPI App: $e');
      if (context.mounted) {
        showNoUpiAppSnackBar(context);
      }
    }
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
        BlocProvider.of<WalletCubit>(context)
            .updateWalletAmount(customerId, widget.subScriptionAmount);
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
              totalAmount: getTotalAmount().toString()),
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
                  final customerId =
                      widget.walletRequestDetails?.customerId?.toString() ??
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
                if (_txnToken != null && _userAgentReady)
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: InAppWebView(
                        initialOptions: buildCheckoutWebViewOptions(
                          userAgent: _userAgent,
                        ),

                        initialUserScripts: Platform.isIOS
                            ? UnmodifiableListView<UserScript>([
                                UserScript(
                                  source: """
                                    (function() {
                                      if (!window.webkit) { window.webkit = {}; }
                                      if (!window.webkit.messageHandlers) { window.webkit.messageHandlers = {}; }
                                      if (!window.webkit.messageHandlers.sendSignalToNative) {
                                        window.webkit.messageHandlers.sendSignalToNative = {
                                          postMessage: function(msg) {
                                            if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                              window.flutter_inappwebview.callHandler('sendSignalToNative', msg);
                                            }
                                          }
                                        };
                                      }
                                    })();
                                  """,
                                  injectionTime:
                                      UserScriptInjectionTime.AT_DOCUMENT_START,
                                ),
                              ])
                            : null,

                        initialData: InAppWebViewInitialData(
                          data: _loadHTML(),
                        ),

                        // ============================================================
                        // WEBVIEW CREATED
                        // ============================================================
                        onWebViewCreated: (controller) {
                          print('');
                          print(
                              '================================================');
                          print('🟢 PAYTM WEBVIEW CREATED');
                          print(
                              '================================================');

                          _webViewController = controller;
                          _setupIosJsBridge(controller);

                          print('🆔 Order ID: $orderId');
                          print('💰 Amount: $amount');
                          print(
                              '🌐 Paytm MID: ${BrandConfig.instance.payment.paytmMid}');
                          print(
                            '🏦 Paytm Gateway: '
                            '${BrandConfig.instance.payment.paytmGatewayBaseUrl}',
                          );
                          print(
                            '🔗 Show Payment URL: '
                            '${BrandConfig.instance.payment.paytmShowPaymentPageUrl(orderId)}',
                          );
                          print(
                            '📞 Response URL: '
                            '${BrandConfig.instance.payment.paytmResponseUrl}',
                          );

                          print(
                              '================================================');
                        },

                        // ============================================================
                        // PAGE STARTED
                        // ============================================================
                        onLoadStart: (
                          controller,
                          Uri? url,
                        ) async {
                          print('');
                          print(
                              '================================================');
                          print('🔵 PAYTM PAGE LOAD START');
                          print(
                              '================================================');
                          print('🌐 URL: $url');
                          print('🆔 Order ID: $orderId');
                          print(
                              '================================================');

                          await _injectIosBridgeShim(controller);
                        },

                        // ============================================================
                        // PAGE LOAD ERROR
                        // ============================================================
                        onLoadError: (
                          controller,
                          url,
                          code,
                          message,
                        ) {
                          print('');
                          print(
                              '================================================');
                          print('🔴 PAYTM WEBVIEW LOAD ERROR');
                          print(
                              '================================================');
                          print('🌐 URL: $url');
                          print('❌ Error Code: $code');
                          print('❌ Message: $message');
                          print(
                              '================================================');

                          if (mounted) {
                            setState(() {
                              _webViewLoading = false;
                            });
                          }
                        },

                        // ============================================================
                        // NAVIGATION
                        // ============================================================
                        shouldOverrideUrlLoading: (
                          InAppWebViewController controller,
                          NavigationAction navigationAction,
                        ) async {
                          final Uri? uri = navigationAction.request.url;

                          debugPrint('');
                          debugPrint(
                              '================================================');
                          debugPrint('🟡 PAYTM NAVIGATION');
                          debugPrint(
                              '================================================');
                          debugPrint('🌐 URI: $uri');
                          debugPrint(
                              '📄 Method: ${navigationAction.request.method}');
                          debugPrint(
                              '================================================');

                          // No URL -> allow normal WebView navigation.
                          if (uri == null) {
                            debugPrint('⚠️ Navigation URI is NULL');
                            return NavigationActionPolicy.ALLOW;
                          }

                          final String page = uri.toString();

                          // ============================================================
                          // CALLBACK CHECK
                          // ============================================================

                          debugPrint(
                              '🔎 Checking whether this is Paytm callback...');
                          debugPrint('🔎 URL: $page');

                          final bool isCallback = _isCallbackPage(page);

                          debugPrint('🎯 Is Callback Page: $isCallback');

                          if (isCallback) {
                            debugPrint('');
                            debugPrint(
                                '================================================');
                            debugPrint('🎯 PAYTM CALLBACK DETECTED');
                            debugPrint(
                                '================================================');
                            debugPrint('🌐 Callback URL: $page');
                            debugPrint('🆔 Order ID: $orderId');
                            debugPrint('➡️ Processing payment response...');
                            debugPrint(
                                '================================================');

                            // Prevent duplicate processing.
                            if (_paymentProcessed) {
                              debugPrint(
                                  '✅ Payment already processed. Cancelling callback navigation.');
                              return NavigationActionPolicy.CANCEL;
                            }

                            await _processPaymentResponse(controller);

                            debugPrint('✅ _processPaymentResponse() completed');

                            // IMPORTANT:
                            // Do not allow the callback page to continue loading.
                            // Otherwise onLoadStop may process the same callback again.
                            return NavigationActionPolicy.CANCEL;
                          }

                          // ============================================================
                          // UPI INTENT
                          // ============================================================

                          debugPrint('🔎 Checking for UPI intent...');

                          if (isUpiIntentUri(uri)) {
                            final result = await launchUpiIntent(uri);
                            if (result.launched) {
                              _externalAppLaunched = true;
                            } else {
                              if (result.fallbackUrl != null) {
                                await controller.loadUrl(
                                  urlRequest: URLRequest(
                                      url: WebUri.uri(result.fallbackUrl!)),
                                );
                              } else if (context.mounted) {
                                showNoUpiAppSnackBar(context);
                              }
                            }
                            return NavigationActionPolicy.CANCEL;
                          }

                          return NavigationActionPolicy.ALLOW;
                        },

// ============================================================
// PAGE LOAD STOP
// ============================================================

                        onLoadStop: (
                          InAppWebViewController controller,
                          Uri? pageUri,
                        ) async {
                          if (mounted) {
                            setState(() {
                              _webViewLoading = false;
                            });
                          }

                          await _injectIosBridgeShim(controller);

                          final String page = pageUri?.toString() ?? '';

                          debugPrint('');
                          debugPrint(
                              '================================================');
                          debugPrint('🟢 PAYTM PAGE LOAD STOP');
                          debugPrint(
                              '================================================');
                          debugPrint('🌐 Loaded URL: $page');
                          debugPrint('🆔 Order ID: $orderId');
                          debugPrint('💰 Amount: $amount');
                          debugPrint(
                              '================================================');

                          if (page.isEmpty) {
                            debugPrint('⚠️ Page URL is empty');
                            return;
                          }

                          // ============================================================
                          // CALLBACK CHECK
                          // ============================================================

                          final bool isCallback = _isCallbackPage(page);

                          debugPrint('🔎 Callback check result: $isCallback');

                          if (isCallback) {
                            debugPrint('');
                            debugPrint(
                                '================================================');
                            debugPrint('🎯 PAYTM CALLBACK PAGE FOUND');
                            debugPrint(
                                '================================================');
                            debugPrint('🌐 Callback URL: $page');
                            debugPrint('🆔 Order ID: $orderId');
                            debugPrint('➡️ Processing payment response...');
                            debugPrint(
                                '================================================');

                            // shouldOverrideUrlLoading normally catches this first.
                            // This is a fallback in case the callback reaches onLoadStop.
                            if (_paymentProcessed) {
                              debugPrint(
                                  '✅ Payment already processed. Skipping duplicate callback.');
                              return;
                            }

                            await _processPaymentResponse(controller);

                            debugPrint(
                                '✅ Payment response processing finished');

                            return;
                          }

                          debugPrint('ℹ️ Normal Paytm page loaded');
                        },
                        // ============================================================
                        // PROGRESS
                        // ============================================================
                        onProgressChanged: (
                          controller,
                          progress,
                        ) {
                          print('📊 Paytm WebView progress: $progress%');
                          if (progress > 50) {
                            _injectIosBridgeShim(controller);
                          }
                        },

                        // ============================================================
                        // CONSOLE
                        // ============================================================
                        onConsoleMessage: (
                          controller,
                          consoleMessage,
                        ) {
                          print('');
                          print('🖥️ PAYTM WEBVIEW CONSOLE');
                          print('🖥️ Level: ${consoleMessage.messageLevel}');
                          print('🖥️ Message: ${consoleMessage.message}');
                          print('');
                        },
                      )),
                if (_prepareError != null)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade600, size: 40),
                            const SizedBox(height: 16),
                            MyAppText(
                              data: _prepareError!,
                              size: 14.sp,
                              align: TextAlign.center,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _prepareCheckout,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_preparingCheckout ||
                    _webViewLoading ||
                    _processingPayment)
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

  /// The transaction ends either on the merchant's own response page or on
  /// Paytm's `theia/paytmCallback`, depending on the `callbackUrl` the server
  /// registered in `initiateTransaction`. Both are treated as the end state.
  bool _isCallbackPage(String page) {
    print('');
    print('🔎 ================= CALLBACK CHECK =================');
    print('🔎 Current page: $page');

    if (page.isEmpty) {
      print('⚠️ Page URL is empty');
      return false;
    }

    // Paytm internal callback
    if (page.contains('theia/paytmCallback')) {
      print('✅ Paytm internal callback detected');
      return true;
    }

    final responseUrl = BrandConfig.instance.payment.paytmResponseUrl;

    print('📞 Configured response URL: $responseUrl');

    if (responseUrl.isNotEmpty) {
      final responseUri = Uri.tryParse(responseUrl);

      final responsePath = responseUri?.path ?? '';

      print('📞 Expected callback path: $responsePath');

      if (responsePath.isNotEmpty && page.contains(responsePath)) {
        print('✅ response.php callback detected');
        return true;
      }
    }

    print('❌ This is NOT a callback page');
    print('🔎 =================================================');

    return false;
  }

  Future<void> _verifyTransactionStatusWithBackend() async {
    if (_paymentProcessed) return;

    debugPrint('[Paytm Verify] 🔄 Starting backend transaction status check for Order $orderId...');

    setState(() {
      _processingPayment = true;
    });

    _processingTimeout?.cancel();
    _processingTimeout = Timer(const Duration(seconds: 45), () {
      if (!_paymentProcessed && mounted) {
        debugPrint('[Paytm Verify] ⛔ Status check timeout reached -> pending');
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.pending
            : OrderStatus.pendingPayment);
      }
    });

    final verifyUrl = BrandConfig.instance.payment.paytmVerifyTransactionUrl;

    // Retry loop: Poll up to 4 times with 2-3s delay to allow gateway reconciliation
    for (int attempt = 1; attempt <= 4; attempt++) {
      if (!mounted || _paymentProcessed) return;

      debugPrint('[Paytm Verify] ⏳ Verification attempt #$attempt / 4...');

      // 1. Check if the WebView navigated to a callback page or has response in DOM
      try {
        final currentUrl = await _webViewController.getUrl();
        final page = currentUrl?.toString() ?? '';

        if (page.isNotEmpty && _isCallbackPage(page)) {
          debugPrint('[Paytm Verify] Callback page reached in WebView');
          await _processPaymentResponse(_webViewController);
          return;
        }

        final rawBodyDynamic = await _webViewController.evaluateJavascript(
          source: "document.body ? document.body.innerText : '';",
        );
        final rawBody = (rawBodyDynamic ?? '').toString().trim();

        if (rawBody.isNotEmpty) {
          final parsed = _parsePaytmResponse(rawBody);
          final statusFromServer = _resolveTxnStatus(parsed);

          if (statusFromServer.isNotEmpty && statusFromServer != 'pending') {
            debugPrint('[Paytm Verify] Resolved status from WebView DOM: $statusFromServer');
            _applyVerifiedStatus(statusFromServer);
            return;
          }
        }
      } catch (e) {
        debugPrint('[Paytm Verify] DOM evaluation error: $e');
      }

      // 2. If backend verify URL is configured, query the backend
      if (verifyUrl.isNotEmpty) {
        try {
          debugPrint('[Paytm Verify] Calling backend verify URL: $verifyUrl');
          final response = await Dio().post(
            verifyUrl,
            options: Options(
              headers: {'Content-Type': 'application/json'},
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
            data: {
              'order_id': orderId,
              'orderId': orderId,
              'mid': _mid,
              'txnToken': _txnToken,
            },
          );

          debugPrint('[Paytm Verify] Backend verify response: ${response.data}');

          if (response.data is Map) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);
            final body = data['body'] is Map ? data['body'] : data;
            final resultInfo = body['resultInfo'] is Map ? body['resultInfo'] : null;
            final resultStatus = resultInfo?['resultStatus']?.toString() ??
                body['STATUS']?.toString() ??
                body['status']?.toString() ??
                '';

            final normalized = _normalizeTxnStatus(resultStatus);
            if (normalized.isNotEmpty && normalized != 'pending') {
              debugPrint('[Paytm Verify] Backend returned status: $normalized');
              _applyVerifiedStatus(normalized);
              return;
            }
          }
        } catch (e) {
          debugPrint('[Paytm Verify] Backend verify call failed: $e');
        }
      }

      // Delay before next attempt
      if (attempt < 4) {
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    if (!mounted || _paymentProcessed) return;

    debugPrint('[Paytm Verify] ⚠️ Final check after retries: marking pending');
    _handlePaymentStatus(widget.isSubscription
        ? SubscriptionStatus.pending
        : OrderStatus.pendingPayment);
  }

  void _applyVerifiedStatus(String statusFromServer) {
    if (widget.isWallet) {
      if (statusFromServer == 'cancelled') {
        _handlePaymentStatus('cancelled', cancelled: true);
      } else {
        _handlePaymentStatus(
            statusFromServer == 'success' ? 'success' : 'failed');
      }
    } else if (statusFromServer == 'success') {
      _handlePaymentStatus(widget.isSubscription
          ? SubscriptionStatus.active
          : OrderStatus.processing);
    } else if (statusFromServer == 'cancelled') {
      _handlePaymentStatus(
          widget.isSubscription
              ? SubscriptionStatus.cancelled
              : OrderStatus.cancelled,
          cancelled: true);
    } else {
      _handlePaymentStatus(widget.isSubscription
          ? SubscriptionStatus.cancelled
          : OrderStatus.failed);
    }
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
      _processingTimeout = Timer(const Duration(seconds: 30), () {
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
        final parsed = _parsePaytmResponse(rawBody);
        print("🧾 Parsed body map: $parsed");

        statusFromServer = _resolveTxnStatus(parsed);
      }

      if (statusFromServer.isEmpty) {
        // Fallback: try to read URL params (STATUS is echoed on some setups).
        try {
          final currentUrl = await controller.getUrl();
          final uri = Uri.parse(currentUrl.toString());
          final statusFromQuery = (uri.queryParameters['STATUS'] ??
                  uri.queryParameters['status'] ??
                  '')
              .toUpperCase();
          if (statusFromQuery.isNotEmpty) {
            statusFromServer = _normalizeTxnStatus(statusFromQuery);
            print("🔎 Found status from query params: $statusFromQuery");
          } else {
            print("⚠ No status in body or query params.");
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

      if (widget.isWallet) {
        if (statusFromServer == 'cancelled') {
          _handlePaymentStatus('cancelled', cancelled: true);
        } else {
          _handlePaymentStatus(
              statusFromServer == 'success' ? 'success' : 'failed');
        }
        return;
      }

      if (statusFromServer == 'success') {
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.active
            : OrderStatus.processing);
      } else if (statusFromServer == 'pending') {
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.pending
            : OrderStatus.pendingPayment);
      } else if (statusFromServer == 'cancelled') {
        _handlePaymentStatus(
            widget.isSubscription
                ? SubscriptionStatus.cancelled
                : OrderStatus.cancelled,
            cancelled: true);
      } else {
        _handlePaymentStatus(widget.isSubscription
            ? SubscriptionStatus.cancelled
            : OrderStatus.failed);
      }
    } catch (e) {
      print("❌ Error processing payment response: $e");
      _handlePaymentStatus(widget.isSubscription
          ? SubscriptionStatus.pending
          : OrderStatus.pendingPayment);
    }
  }

  /// The response page can render the Paytm payload three ways: PHP `print_r`
  /// (`[STATUS] => TXN_FAILURE`), JSON, or plain `key=value` lines. All three
  /// are reduced to a flat map here.
  Map<String, String> _parsePaytmResponse(String input) {
    final result = <String, String>{};

    final printR = RegExp(r'\[\s*([A-Za-z0-9_]+)\s*\]\s*=>\s*([^\n\r]*)');
    for (final match in printR.allMatches(input)) {
      result[match.group(1)!.trim()] = match.group(2)!.trim();
    }
    if (result.isNotEmpty) return result;

    try {
      final decoded = json.decode(input.trim());
      if (decoded is Map) {
        decoded.forEach((key, value) {
          if (value is Map) {
            value.forEach((nestedKey, nestedValue) {
              result[nestedKey.toString()] = nestedValue?.toString() ?? '';
            });
          } else {
            result[key.toString()] = value?.toString() ?? '';
          }
        });
      }
    } catch (_) {
      // Not JSON - fall through to the key=value pass.
    }
    if (result.isNotEmpty) return result;

    for (final part in input.split(RegExp(r'[&\n\r]'))) {
      final separator = part.indexOf('=');
      if (separator > 0) {
        final key = part.substring(0, separator).trim();
        if (key.isNotEmpty) {
          result[key] = part.substring(separator + 1).trim();
        }
      }
    }

    return result;
  }

  /// Reduces whatever the callback page rendered to `success`, `pending`,
  /// `cancelled`, `failed`, or an empty string when nothing usable was found.
  String _resolveTxnStatus(Map<String, String> parsed) {
    String? valueOf(List<String> keys) {
      for (final entry in parsed.entries) {
        if (keys.any((k) => k.toLowerCase() == entry.key.toLowerCase()) &&
            entry.value.trim().isNotEmpty) {
          return entry.value;
        }
      }
      return null;
    }

    final status = valueOf(['STATUS', 'resultStatus', 'RESULT']);
    final normalized = status == null ? '' : _normalizeTxnStatus(status);

    // 141 ("User has not completed transaction") and 810 ("Payment cancelled
    // by user") are aborts rather than gateway failures.
    if (normalized == 'failed') {
      final respCode = valueOf(['RESPCODE', 'resultCode']);
      if (respCode == '141' || respCode == '810') return 'cancelled';
    }

    return normalized;
  }

  String _normalizeTxnStatus(String value) {
    final status = value.trim().toUpperCase();
    if (status.contains('TXN_SUCCESS') ||
        status == 'S' ||
        status == 'SUCCESS') {
      return 'success';
    }
    if (status.contains('PENDING') || status == 'P') return 'pending';
    if (status.contains('CANCEL') || status.contains('ABORT')) {
      return 'cancelled';
    }
    if (status.contains('TXN_FAILURE') ||
        status == 'F' ||
        status.contains('FAIL')) {
      return 'failed';
    }
    return '';
  }

  String _loadHTML() {
    final action =
        BrandConfig.instance.payment.paytmShowPaymentPageUrl(orderId);

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
      <form id='f' name='f' method='post' action='$action'>
        <input type="hidden" name="mid" value="$_mid">
        <input type="hidden" name="orderId" value="$orderId">
        <input type="hidden" name="txnToken" value="$_txnToken">
      </form>
    </body>
  </html>
  """;

    return html;
  }
}
