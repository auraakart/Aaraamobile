import 'package:aaraa_kart/app/router/app_routes.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/data/model/create_subscription_request.dart';
import 'package:aaraa_kart/data/model/create_subscription_response.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/order_create_request.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:aaraa_kart/data/model/order_success_route_model.dart';
import 'package:aaraa_kart/data/model/subscription_product_detail_model.dart';
import 'package:aaraa_kart/presentation/auth/email_screen.dart';
import 'package:aaraa_kart/presentation/auth/login_screen.dart';
import 'package:aaraa_kart/presentation/auth/name_screen.dart';
import 'package:aaraa_kart/presentation/auth/otp_screen.dart';
import 'package:aaraa_kart/presentation/auth/welcome_screen.dart';
import 'package:aaraa_kart/presentation/cart/cart_screen.dart';
import 'package:aaraa_kart/presentation/checkout/checkout_screen.dart';
import 'package:aaraa_kart/presentation/common/webview_screen.dart';
import 'package:aaraa_kart/presentation/home/home_screen.dart';
import 'package:aaraa_kart/presentation/home/product_details.dart';
import 'package:aaraa_kart/presentation/home/product_list.dart';
import 'package:aaraa_kart/presentation/location/google_maps_screen.dart';
import 'package:aaraa_kart/presentation/location/location_selection_screen.dart';
import 'package:aaraa_kart/presentation/menu/edit_profile.dart';

import 'package:aaraa_kart/presentation/menu/menu_screen.dart';
import 'package:aaraa_kart/presentation/order/order_failed_screen.dart';
import 'package:aaraa_kart/presentation/order/order_success_screen.dart';
import 'package:aaraa_kart/presentation/payment/payment_screen.dart';
import 'package:aaraa_kart/presentation/payment/paytm_webview_screen.dart';
import 'package:aaraa_kart/presentation/splash/splash_screen.dart';
import 'package:aaraa_kart/presentation/subscriptions/create_subscription.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscriptions_history.dart';
import 'package:aaraa_kart/presentation/wallet/wallet_screen.dart';
import 'package:aaraa_kart/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  static late BuildContext context;

  AppRoute.setStream(BuildContext ctx) {
    context = ctx;
  }

  static GoRouter appRouter = GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => LoginScreen(
          isGuestMode: state.extra != null
              ? (state.extra as Map<String, dynamic>)['guestMode']
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.otp.path,
        name: AppRoutes.otp.name,
        builder: (context, state) => OtpVerificationScreen(
          phoneNumber: state.extra != null
              ? (state.extra as Map<String, dynamic>)['phoneNumber']
              : '',
        ),
      ),
      GoRoute(
        path: AppRoutes.bottomBar.path,
        name: AppRoutes.bottomBar.name,
        builder: (context, state) => const BottomNavBar(
          selectedIndex: 0,
        ),
      ),
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile.path,
        name: AppRoutes.profile.name,
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.productList.path,
        name: AppRoutes.productList.name,
        builder: (context, state) => ProductListScreen(
          appTitle: state.extra != null
              ? (state.extra as Map<String, dynamic>)['appTitle']
              : '',
          category: state.extra != null
              ? (state.extra as Map<String, dynamic>)['category']
              : '',
        ),
      ),
      GoRoute(
        path: AppRoutes.payment.path,
        name: AppRoutes.payment.name,
        builder: (context, state) {
          final extraMap = state.extra as Map<String, dynamic>;
          return PaymentScreen(
              orderRequestDetails:
                  extraMap['orderRequestDetails'] as OrderCreateRequest?,
              orderResponseDetails:
                  extraMap['orderResponseDetails'] as OrderCreateProducts?,
              subRequestDetails: extraMap['subRequestDetails']
                  as CreateSubscriptionRequestModel?,
              isSubscription: extraMap['isSubscription'],
              walletRequestDetails:
                  extraMap['walletRequestDetails'] as GetAddressResponse?,
              isWallet: extraMap['isWallet'],
              subOrderID: extraMap['subOrderID'],
              subResponseDetails: extraMap['subResponseDetails']
                  as CreateSubscriptionResponseModel?,
              subScriptionAmount: extraMap['subScriptionAmount']);
        },
      ),
      GoRoute(
        path: AppRoutes.paytmPayment.path,
        name: AppRoutes.paytmPayment.name,
        builder: (context, state) {
          final extraMap = state.extra as Map<String, dynamic>;
          return PaytmWebviewScreen(
              orderRequestDetails:
                  extraMap['orderRequestDetails'] as OrderCreateRequest?,
              orderResponseDetails:
                  extraMap['orderResponseDetails'] as OrderCreateProducts?,
              subRequestDetails: extraMap['subRequestDetails']
                  as CreateSubscriptionRequestModel?,
              isSubscription: extraMap['isSubscription'],
              walletRequestDetails:
                  extraMap['walletRequestDetails'] as GetAddressResponse?,
              isWallet: extraMap['isWallet'],
              subOrderID: extraMap['subOrderID'],
              subResponseDetails: extraMap['subResponseDetails']
                  as CreateSubscriptionResponseModel?,
              subScriptionAmount: extraMap['subScriptionAmount']);
        },
      ),
      GoRoute(
        path: AppRoutes.productDetails.path,
        name: AppRoutes.productDetails.name,
        builder: (context, state) {
          final extraMap = state.extra as Map<String, dynamic>?;

          if (extraMap == null) {
            return const Scaffold(
              body: Center(
                child: Text('Product data not found'),
              ),
            );
          }

          return ProductDetailsScreen(
            hasSubscribed: extraMap['hasSubscribed'] as bool? ?? false,
            subProductDetails:
                (extraMap['subProductDetails'] as List<dynamic>?)?.map((e) {
                      if (e is SubscriptionProductDetailModel) {
                        return e;
                      } else if (e is Map<String, dynamic>) {
                        return SubscriptionProductDetailModel.fromJson(e);
                      } else {
                        throw Exception(
                            "Invalid type in subProductDetails: ${e.runtimeType}");
                      }
                    }).toList() ??
                    <SubscriptionProductDetailModel>[],
            productID: extraMap['productID'] as String? ?? '',
            productName: extraMap['productName'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.googleMaps.path,
        name: AppRoutes.googleMaps.name,
        builder: (context, state) => const GoogleMapsScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationSelection.path,
        name: AppRoutes.locationSelection.name,
        builder: (context, state) => const LocationSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet.path,
        name: AppRoutes.wallet.name,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart.path,
        name: AppRoutes.cart.name,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout.path,
        name: AppRoutes.checkout.name,
        builder: (context, state) => CheckoutScreen(
            deliveryNote: state.extra != null
                ? (state.extra as Map<String, dynamic>)['deliveryNote']
                : "",
            subscriptionDetails: state.extra != null
                ? (state.extra as Map<String, dynamic>)['subscriptionDetails']
                : "",
            isSubscription: state.extra != null
                ? (state.extra as Map<String, dynamic>)['isSubscription']
                : false),
      ),
      GoRoute(
        path: AppRoutes.nameScreen.path,
        name: AppRoutes.nameScreen.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return NameScreen(
            phoneNumber: extra['phoneNumber'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.emailScreen.path,
        name: AppRoutes.emailScreen.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return EmailScreen(
            phoneNumber: extra['phoneNumber'],
            name: extra['name'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.welcome.path,
        name: AppRoutes.welcome.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WelcomeScreen(
            name: extra['name'],
            phoneNumber: extra['phoneNumber'],
            email: extra['email'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile.path,
        name: AppRoutes.editProfile.name,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess.path,
        name: AppRoutes.orderSuccess.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          return OrderSuccessScreen(
              isSubscription: extra["isSubscription"],
              orderDetails: extra["orderDetails"] as OrderSuccessRouteModel);
        },
      ),
      GoRoute(
        path: AppRoutes.orderFailed.path,
        name: AppRoutes.orderFailed.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OrderFailedScreen(
            errorMessage: extra?["errorMessage"] as String?,
            errorCode: extra?["errorCode"] as String?,
            transactionId: extra?["transactionId"] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createSubscription.path,
        name: AppRoutes.createSubscription.name,
        builder: (context, state) => CreateSubscription(
          productDetails: state.extra != null
              ? (state.extra as Map<String, dynamic>)['productDetails']
              : '',
        ),
      ),
      GoRoute(
        path: AppRoutes.tnc.path,
        name: AppRoutes.tnc.name,
        builder: (context, state) => WebViewScreen(
          title: 'Terms and Conditions',
          url: BrandConfig.instance.content.termsAndConditionsUrl,
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy.path,
        name: AppRoutes.privacy.name,
        builder: (context, state) => WebViewScreen(
          title: 'Privacy Policy',
          url: BrandConfig.instance.content.privacyPolicyUrl,
        ),
      ),
      GoRoute(
        path: AppRoutes.faq.path,
        name: AppRoutes.faq.name,
        builder: (context, state) => WebViewScreen(
          title: 'FAQ',
          url: BrandConfig.instance.content.faqUrl,
        ),
      ),
      GoRoute(
        path: AppRoutes.subHistory.path,
        name: AppRoutes.subHistory.name,
        builder: (context, state) => SubscriptionsHistoryScreen(),
      ),
    ],
  );
}


