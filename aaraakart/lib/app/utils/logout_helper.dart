import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/cart/cart_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void performLogout(BuildContext context) {
  context.read<AuthCubit>().reset();
  context.read<SubscriptionsCubit>().reset();
  context.read<WalletCubit>().reset();
  context.read<OrderCubit>().reset();
  context.read<CartCubit>().clearCart();
  context.read<StorageCubit>().setUserData(null);
  context.read<StorageCubit>().setIsGuestMode(null);
  context.read<StorageCubit>().removeAddress();
}


