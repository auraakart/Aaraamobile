import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/errors/app_exception.dart';
import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/create_subscription_request.dart';
import 'package:aaraa_kart/data/model/create_subscription_response.dart';
import 'package:aaraa_kart/data/model/get_customer_subs.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:aaraa_kart/data/model/product_details_response.dart';
import 'package:aaraa_kart/data/model/update_subscription_request.dart';

class SubscriptionsRepository {
  final Dio dio;
  final Dio dioV2;

  SubscriptionsRepository(this.dio, this.dioV2);

  Future<List<GetCustomerSubscriptionsResponseModel>> getSubscriptios(
      String customerID) async {
    try {
      Map<String, dynamic> payload = {
        "customer": customerID,
        "customer_id": customerID,
      };

      final response = await dio.get(ApiConstants.GetSubscriptions,
          queryParameters: payload);

      if (response.data is List) {
        return (response.data as List)
            .map((item) => GetCustomerSubscriptionsResponseModel.fromJson(item))
            .toList();
      } else if (response.data is Map &&
          response.data['subscriptions'] is List) {
        return (response.data['subscriptions'] as List)
            .map((item) => GetCustomerSubscriptionsResponseModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (_) {
      throw const RepositoryException(
        'Unable to load subscriptions. Please try again.',
      );
    }
  }

  Future<String> getSubscriptionVariatonsID(
      String productID, String plan) async {
    try {
      Map<String, dynamic> payload = {
        "product_id": productID,
        "attributes": {"plan": plan}
      };
      final response = await dio.get(ApiConstants.GetVariantID, data: payload);

      return response.data.toString();
    } catch (_) {
      throw const RepositoryException(
        'Unable to load the subscription option. Please try again.',
      );
    }
  }

  Future<GetProductDetaillsResponseModel> getSubscriptionVariatons(
      String productID, String variationID) async {
    try {
      final response = await dio.get(
          '${ApiConstants.Products}/$productID/${ApiConstants.GetSubscriptionsVariations}/$variationID');

      return GetProductDetaillsResponseModel.fromJson(response.data);
    } catch (_) {
      throw const RepositoryException(
        'Unable to load subscription details. Please try again.',
      );
    }
  }

  Future<CreateSubscriptionResponseModel> createSubscription(
      CreateSubscriptionRequestModel request) async {
    try {
      final response = await dio.post(
        ApiConstants.CreateSubscription,
        data: request.toJson(),
      );

      return CreateSubscriptionResponseModel.fromJson(response.data);
    } catch (_) {
      throw const RepositoryException(
        'Unable to create the subscription. Please try again.',
      );
    }
  }

  Future<OrderCreateResponseModel> updateSubscription(
      String orderID, UpdateSubscriptionRequest request) async {
    try {
      final response = await dio.put(
        '${ApiConstants.GetSubscriptions}/$orderID',
        data: request.toJson(),
      );

      return OrderCreateResponseModel.fromJson(response.data);
    } catch (_) {
      throw const RepositoryException(
        'Unable to update the subscription. Please try again.',
      );
    }
  }

  Future<String> pauseSubscription({
    required String subscriptionId,
    required String customerId,
    required dynamic pauseDates,
    String pauseType = "temporary",
  }) async {
    final isPermanent = pauseType == "permanent";
    final formattedDates = isPermanent ? [] : pauseDates;

    final Response<dynamic> response;
    try {
      response = await dioV2.post(
        ApiConstants.PauseSubscription,
        data: {
          "subscription_id": int.tryParse(subscriptionId) ?? subscriptionId,
          "customer_id": int.tryParse(customerId) ?? customerId,
          "pause_dates": formattedDates,
          "pause_type": pauseType,
        },
      );
    } catch (_) {
      throw const RepositoryException(
        'Unable to pause the subscription. Please try again.',
      );
    }

    if (!isPermanent) {
      try {
        await dio.put(
          '${ApiConstants.GetSubscriptions}/$subscriptionId',
          data: {
            "status": "active",
            "meta_data": [
              {"key": "pause_dates", "value": formattedDates},
              {"key": "_pause_dates", "value": formattedDates},
              {"key": "subscription_pause_dates", "value": formattedDates},
              {"key": "_subscription_pause_dates", "value": formattedDates},
              {"key": "paused_dates", "value": formattedDates},
              {"key": "_paused_dates", "value": formattedDates},
              {"key": "_aaraa_pause_dates", "value": formattedDates},
              {"key": "aaraa_pause_dates", "value": formattedDates},
              {"key": "_wcfmu_pause_dates", "value": formattedDates},
              {"key": "wcfmu_pause_dates", "value": formattedDates},
              {
                "key": "pause_date",
                "value": formattedDates.isNotEmpty ? formattedDates.first : ""
              },
              {
                "key": "_pause_date",
                "value": formattedDates.isNotEmpty ? formattedDates.first : ""
              },
              {"key": "pause_type", "value": "temporary"},
              {"key": "_pause_type", "value": "temporary"},
              {"key": "is_paused", "value": false},
              {"key": "_is_paused", "value": false},
              {"key": "subscription_is_paused", "value": false},
              {"key": "_subscription_is_paused", "value": false},
            ],
          },
        );
      } catch (_) {
        throw const RepositoryException(
          'The pause request was received, but synchronization did not complete. Refresh before retrying.',
        );
      }
    }

    if (response.data is Map && response.data['message'] != null) {
      return response.data['message'].toString();
    }

    return 'Subscription paused successfully';
  }

  Future<String> resumeSubscription({
    required String subscriptionId,
    required String customerId,
    String? billingPeriod,
    dynamic billingInterval,
    dynamic startDate,
    dynamic currentNextPaymentDate,
  }) async {
    final subId = int.tryParse(subscriptionId) ?? subscriptionId;
    final custId = int.tryParse(customerId) ?? customerId;

    final Response<dynamic> response;
    try {
      response = await dioV2.post(
        ApiConstants.ResumeSubscription,
        data: {
          "subscription_id": subId,
          "customer_id": custId,
        },
      );
    } catch (_) {
      throw const RepositoryException(
        'Unable to resume the subscription. Please try again.',
      );
    }

    try {
      await dioV2.post(
        ApiConstants.PauseSubscription,
        data: {
          "subscription_id": subId,
          "customer_id": custId,
          "pause_dates": [],
          "pause_type": "temporary",
        },
      );
    } catch (_) {
      throw const RepositoryException(
        'The resume request was received, but synchronization did not complete. Refresh before retrying.',
      );
    }

    try {
      await dio.put(
        '${ApiConstants.GetSubscriptions}/$subscriptionId',
        data: {
          "status": "active",
          "meta_data": [
            {"key": "pause_dates", "value": []},
            {"key": "_pause_dates", "value": []},
            {"key": "subscription_pause_dates", "value": []},
            {"key": "_subscription_pause_dates", "value": []},
            {"key": "paused_dates", "value": []},
            {"key": "_paused_dates", "value": []},
            {"key": "_aaraa_pause_dates", "value": []},
            {"key": "aaraa_pause_dates", "value": []},
            {"key": "_wcfmu_pause_dates", "value": []},
            {"key": "wcfmu_pause_dates", "value": []},
            {"key": "pause_date", "value": ""},
            {"key": "_pause_date", "value": ""},
            {"key": "pause_type", "value": ""},
            {"key": "_pause_type", "value": ""},
            {"key": "is_paused", "value": false},
            {"key": "_is_paused", "value": false},
            {"key": "subscription_is_paused", "value": false},
            {"key": "_subscription_is_paused", "value": false},
          ],
        },
      );
    } catch (_) {
      throw const RepositoryException(
        'The subscription resumed, but legacy synchronization did not complete. Refresh before retrying.',
      );
    }

    if (response.data is Map && response.data['message'] != null) {
      return response.data['message'].toString();
    }

    return 'Subscription resumed successfully';
  }
}
