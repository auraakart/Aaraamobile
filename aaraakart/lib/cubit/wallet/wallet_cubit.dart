import 'package:aaraa_kart/cubit/wallet/wallet_state.dart';
import 'package:aaraa_kart/data/model/get_wallet_transactions_model.dart';
import 'package:aaraa_kart/domain/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  String? cachedAmount;
  List<GetWalletTransactionsResponseModel>? cachedTransactions;

  WalletCubit(this._repository) : super(WalletInitial());

  Future<void> getWalletAmount(dynamic customerID) async {
    if (customerID == null || customerID.toString().isEmpty) return;
    emit(GetWalletAmountLoading(isLoading: true));

    try {
      final result = await _repository.getWalletAmount(customerID);

      cachedAmount = result;
      emit(GetWalletAmountSuccess(walletAmount: result));
    } catch (e) {
      emit(GetWalletAmountError(e.toString()));
    }
  }

  Future<void> updateWalletAmount(dynamic customerID, dynamic amount) async {
    if (customerID == null || customerID.toString().isEmpty) return;
    emit(UpdateWalletAmountLoading(isLoading: true));

    try {
      final result = await _repository.updateWalletAmount(customerID, amount);

      if (result.balance != null && result.balance!.isNotEmpty) {
        cachedAmount = result.balance;
      }
      emit(UpdateWalletAmountSuccess(walletResponse: result));

      // Re-fetch latest wallet balance and transactions from server
      await getWalletAmount(customerID);
      await getWalletTransactions(customerID);
    } catch (e) {
      emit(UpdateWalletAmountError(e.toString()));
    }
  }

  Future<void> getWalletTransactions(dynamic customerID) async {
    if (customerID == null || customerID.toString().isEmpty) return;
    emit(GetWalletTransactionsLoading(isLoading: true));

    try {
      final result = await _repository.getWalletTransactionHistory(customerID);

      cachedTransactions = result;
      emit(GetWalletTransactionsSuccess(transactionsData: result));
    } catch (e) {
      emit(GetWalletTransactionsError(e.toString()));
    }
  }

  void reset() {
    cachedAmount = null;
    cachedTransactions = null;
    emit(WalletInitial());
  }
}
