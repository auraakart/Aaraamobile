import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaraa_kart/app/router/app_router.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/core/di/injection.dart';
import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/banner/banner_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/category/category_cubit.dart';
import 'package:aaraa_kart/cubit/google_maps/maps_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/product/product_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_cubit.dart';
import 'package:aaraa_kart/core/notifications/in_app_messaging_service.dart';
import 'package:aaraa_kart/core/notifications/push_notification_service.dart';
import 'package:aaraa_kart/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BrandConfig.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  setupDI();

  if (kDebugMode) {
    CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  }

  await ScreenUtil.ensureScreenSize();

  runApp(const MyApp());

  // Keep notification permission user-driven. PushNotificationService.initialize()
  // requests notification permission, so it must be invoked from the product's
  // explicit permission/onboarding flow rather than automatically at app launch.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        minTextAdapt: true,
        splitScreenMode: true,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: (context) {
            ScreenUtil.init(context);
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<AuthCubit>()),
                BlocProvider(create: (_) => getIt<ProductCubit>()),
                BlocProvider(create: (_) => getIt<MapsCubit>()),
                BlocProvider(create: (_) => getIt<CategoryCubit>()),
                BlocProvider(create: (_) => getIt<CartCubit>()),
                BlocProvider(create: (_) => getIt<OrderCubit>()),
                BlocProvider(create: (_) => getIt<StorageCubit>()),
                BlocProvider(create: (_) => getIt<SubscriptionsCubit>()),
                BlocProvider(create: (_) => getIt<WalletCubit>()),
                BlocProvider(create: (_) => getIt<BannerCubit>()),
              ],
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: BrandConfig.instance.appName,
                theme: AppTheme.light,
                themeMode: ThemeMode.light,
                routerConfig: AppRoute.appRouter,
              ),
            );
          }),
        ),
      ),
    );
  }
}
