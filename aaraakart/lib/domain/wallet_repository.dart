import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/di/injection.dart';
import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/get_wallet_transactions_model.dart';
import 'package:aaraa_kart/data/model/update_wallet_amount_response.dart';

class WalletRepository {
  Dio dio = getIt<Dio>(instanceName: 'walletDio');

  WalletRepository(this.dio);

  Future<String> getWalletAmount(dynamic customerID) async {
    try {
      final response = await dio.get(
        customerID.toString(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data is Map) {
        if (response.data['balance'] != null) {
          return response.data['balance'].toString();
        }
        if (response.data['wallet_balance'] != null) {
          return response.data['wallet_balance'].toString();
        }
      }
      return response.data?.toString() ?? '0';
    } catch (e) {
      throw Exception('Failed to Get Wallet Amount: $e');
    }
  }

  Future<UpdateWalletAmountResponseModel> updateWalletAmount(
      dynamic customerID, dynamic amount) async {
    final api = BrandConfig.instance.api;

    try {
      Map<String, dynamic> payload = {
        "consumer_key": api.walletConsumerKey,
        "consumer_secret": api.walletConsumerSecret,
        "amount": amount,
        "action": "credit",
        "transaction_detail": "credit by you"
      };
      final response = await dio.put(
        customerID.toString(),
        data: payload,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return UpdateWalletAmountResponseModel.fromJson(response.data);
      } else if (response.data is String) {
        return updateWalletAmountResponseModelFromJson(response.data);
      } else {
        return UpdateWalletAmountResponseModel.fromJson(
            Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      throw Exception('Failed to Update Wallet Amount: $e');
    }
  }

  Future<List<GetWalletTransactionsResponseModel>> getWalletTransactionHistory(
      dynamic customerID) async {
    try {
      final url = "${ApiConstants.GetWalletTransactions}/${customerID.toString()}";

      final response = await dio.get(url);

      if (response.data is List) {
        return (response.data as List)
            .map((item) => GetWalletTransactionsResponseModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to Get Wallet History: $e');
    }
  }
}


