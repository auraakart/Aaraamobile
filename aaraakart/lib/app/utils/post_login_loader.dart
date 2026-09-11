import 'package:aaraa_kart/cubit/auth/auth_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/wallet/wallet_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> loadUserAppData(BuildContext context, String customerID) async {
  await Future.wait([
    context.read<SubscriptionsCubit>().getSubscriptions(customerID),
    context.read<WalletCubit>().getWalletAmount(customerID),
    context.read<WalletCubit>().getWalletTransactions(customerID),
    context.read<AuthCubit>().listAddress(customerID),
    context.read<OrderCubit>().getOrderList(
        customerID, 1, DateTime(2024, 1, 1), DateTime.now()),
  ]);

  if (context.mounted) {
    await context.read<StorageCubit>().getAddress();
  }
}


