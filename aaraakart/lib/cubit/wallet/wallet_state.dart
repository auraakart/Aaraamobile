import 'package:aaraa_kart/data/model/get_wallet_transactions_model.dart';
import 'package:aaraa_kart/data/model/update_wallet_amount_response.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class GetWalletAmountLoading extends WalletState {
  final bool isLoading;
  GetWalletAmountLoading({this.isLoading = true});
}

class GetWalletAmountSuccess extends WalletState {
  final String walletAmount;

  GetWalletAmountSuccess({
    required this.walletAmount,
  });
}

class GetWalletAmountError extends WalletState {
  final String message;

  GetWalletAmountError(this.message);
}

class UpdateWalletAmountLoading extends WalletState {
  final bool isLoading;
  UpdateWalletAmountLoading({this.isLoading = true});
}

class UpdateWalletAmountSuccess extends WalletState {
  UpdateWalletAmountResponseModel? walletResponse;

  UpdateWalletAmountSuccess({
    this.walletResponse,
  });
}

class UpdateWalletAmountError extends WalletState {
  final String message;

  UpdateWalletAmountError(this.message);
}

class GetWalletTransactionsLoading extends WalletState {
  final bool isLoading;
  GetWalletTransactionsLoading({this.isLoading = true});
}

class GetWalletTransactionsSuccess extends WalletState {
  final List<GetWalletTransactionsResponseModel> transactionsData;

  GetWalletTransactionsSuccess({
    required this.transactionsData,
  });
}

class GetWalletTransactionsError extends WalletState {
  final String message;

  GetWalletTransactionsError(this.message);
}


