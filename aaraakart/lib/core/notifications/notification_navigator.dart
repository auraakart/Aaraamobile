import 'package:aaraa_kart/app/router/app_router.dart';
import 'package:aaraa_kart/app/router/app_routes.dart';
import 'package:flutter/widgets.dart';

class NotificationNavigator {
  const NotificationNavigator._();

  static Map<String, dynamic>? _pending;

  static void handle(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final router = AppRoute.appRouter;
    if (router.routerDelegate.navigatorKey.currentState == null) {
      _pending = data;
      return;
    }

    _navigate(data);
  }

  static void flushPending() {
    final data = _pending;
    if (data == null) return;
    _pending = null;

    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate(data));
  }

  static void _navigate(Map<String, dynamic> data) {
    final router = AppRoute.appRouter;
    final type = data['type']?.toString().toLowerCase();

    switch (type) {
      case 'product':
        final productId =
            (data['productId'] ?? data['product_id'] ?? data['id'])?.toString();
        if (productId == null || productId.isEmpty) return;

        router.pushNamed(
          AppRoutes.productDetails.name,
          extra: <String, dynamic>{
            'productID': productId,
            'productName':
                (data['productName'] ?? data['product_name'] ?? '').toString(),
            'hasSubscribed': false,
          },
        );
        break;

      case 'category':
      case 'productlist':
        final category = (data['category'] ?? '').toString();
        router.pushNamed(
          AppRoutes.productList.name,
          extra: <String, dynamic>{
            'appTitle': (data['title'] ?? category).toString(),
            'category': category,
          },
        );
        break;

      case 'cart':
        router.pushNamed(AppRoutes.cart.name);
        break;

      case 'wallet':
        router.pushNamed(AppRoutes.wallet.name);
        break;

      case 'orders':
      case 'subscriptions':
        router.pushNamed(AppRoutes.subHistory.name);
        break;

      case 'home':
        router.pushNamed(AppRoutes.bottomBar.name);
        break;

      case 'route':
        final path = data['path']?.toString();
        if (path != null && path.startsWith('/')) router.push(path);
        break;

      default:
        break;
    }
  }
}


