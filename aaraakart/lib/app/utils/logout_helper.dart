import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> performLogout(BuildContext context) async {
  context.read<AuthCubit>().reset();
  context.read<SubscriptionsCubit>().reset();
  context.read<WalletCubit>().reset();
  context.read<OrderCubit>().reset();
  context.read<CartCubit>().clearCart();

  final storage = context.read<StorageCubit>();
  await storage.setUserData(null);
  await storage.setIsGuestMode(null);
  await storage.removeAddress();
}
