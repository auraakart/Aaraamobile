import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/core/network/dio_client.dart';
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
import 'package:aaraa_kart/domain/auth_repository.dart';
import 'package:aaraa_kart/domain/banner_repository.dart';
import 'package:aaraa_kart/domain/category_repository.dart';
import 'package:aaraa_kart/domain/google_map_repository.dart';
import 'package:aaraa_kart/domain/order_repository.dart';
import 'package:aaraa_kart/domain/product_repository.dart';
import 'package:aaraa_kart/domain/subscriptions_repository.dart';
import 'package:aaraa_kart/domain/wallet_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDI() {
  final api = BrandConfig.instance.api;

  getIt.registerLazySingleton<Dio>(
    () => DioClient.farmersVillageAPI(
      api.wooConsumerKey,
      api.wooConsumerSecret,
    ),
    instanceName: 'farmersVillageDio',
  );

  getIt.registerLazySingleton<Dio>(
    () => DioClient.farmersVillageAPIv2(
      api.wooConsumerKey,
      api.wooConsumerSecret,
    ),
    instanceName: 'farmersVillageDioV2',
  );
  getIt.registerLazySingleton<Dio>(
    () => DioClient.googleMapsAPI(AppConstants.gcpkey),
    instanceName: 'googleMapsDio',
  );

  getIt.registerLazySingleton<Dio>(
    () => DioClient.walletAPI(),
    instanceName: 'walletDio',
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(getIt<Dio>(instanceName: 'farmersVillageDio')),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<Dio>(instanceName: 'farmersVillageDio')),
  );
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepository(getIt<Dio>(instanceName: 'farmersVillageDioV2')),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      getIt<Dio>(instanceName: 'farmersVillageDio'),
      getIt<Dio>(instanceName: 'farmersVillageDioV2'),
    ),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepository(getIt<Dio>(instanceName: 'farmersVillageDio')),
  );
  getIt.registerLazySingleton<GoogleMapRepository>(
    () => GoogleMapRepository(getIt<Dio>(instanceName: 'googleMapsDio')),
  );
  getIt.registerLazySingleton<SubscriptionsRepository>(
    () => SubscriptionsRepository(
      getIt<Dio>(instanceName: 'farmersVillageDio'),
      getIt<Dio>(instanceName: 'farmersVillageDioV2'),
    ),
  );
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepository(getIt<Dio>(instanceName: 'walletDio')),
  );

  getIt.registerFactory(() => ProductCubit(getIt<ProductRepository>()));
  getIt.registerFactory(() => MapsCubit(getIt<GoogleMapRepository>()));
  getIt.registerFactory(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory(() => OrderCubit(getIt<OrderRepository>()));
  getIt.registerFactory(
      () => SubscriptionsCubit(getIt<SubscriptionsRepository>()));
  getIt.registerFactory<CartCubit>(() => CartCubit());
  getIt.registerFactory<StorageCubit>(() => StorageCubit());
  getIt.registerFactory<CategoryCubit>(
      () => CategoryCubit(getIt<CategoryRepository>()));
  getIt.registerFactory<WalletCubit>(
      () => WalletCubit(getIt<WalletRepository>()));
  getIt.registerFactory<BannerCubit>(
      () => BannerCubit(getIt<BannerRepository>()));
}


