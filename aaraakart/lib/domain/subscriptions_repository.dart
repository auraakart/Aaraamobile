import 'package:dio/dio.dart';
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

      // [DEBUG LOG - INVESTIGATION ONLY]
      // ignore: avoid_print
      print('=== [DEBUG] GET /subscriptions API RESPONSE ===');
      // ignore: avoid_print
      print('HTTP Status: ${response.statusCode}');
      // ignore: avoid_print
      print('Customer ID: $customerID');
      // ignore: avoid_print
      print('Raw Response Data: ${response.data}');

      if (response.data is List) {
        for (final item in (response.data as List)) {
          if (item is Map) {
            // ignore: avoid_print
            print('--- [DEBUG RAW SUB ITEM] ---');
            // ignore: avoid_print
            print('Sub ID: ${item['id']}, Status: ${item['status']}');
            // ignore: avoid_print
            print('billing_period: ${item['billing_period']}, billing_interval: ${item['billing_interval']}');
            // ignore: avoid_print
            print('delivery_schedule (top-level): ${item['delivery_schedule']}');
            // ignore: avoid_print
            print('start_date_gmt: ${item['start_date_gmt']}, next_payment_date_gmt: ${item['next_payment_date_gmt']}');
            final meta = item['meta_data'];
            if (meta is List) {
              for (final m in meta) {
                if (m is Map && (m['key'] == 'delivery_schedule' || m['key'] == '_delivery_schedule' || m['key'] == 'schedule')) {
                  // ignore: avoid_print
                  print('meta_data schedule key: ${m['key']} => value: ${m['value']}');
                }
              }
            }
          }
        }
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
    } catch (e) {
      throw Exception('Failed to get subscriptions: $e');
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
    } catch (e) {
      throw Exception('Failed to get variation Id: $e');
    }
  }

  Future<GetProductDetaillsResponseModel> getSubscriptionVariatons(
      String productID, String variationID) async {
    try {
      final response = await dio.get(
          '${ApiConstants.Products}/$productID/${ApiConstants.GetSubscriptionsVariations}/$variationID');

      return GetProductDetaillsResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get product details: $e');
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
    } catch (e) {
      throw Exception('Failed to Create Subscription: $e');
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
    } catch (e) {
      throw Exception('Failed to Update Subscription: $e');
    }
  }

  Future<String> pauseSubscription({
    required String subscriptionId,
    required String customerId,
    required dynamic pauseDates,
    String pauseType = "temporary",
  }) async {
    try {
      final isPermanent = pauseType == "permanent";
      final formattedDates = isPermanent ? [] : pauseDates;

      final response = await dioV2.post(
        ApiConstants.PauseSubscription,
        data: {
          "subscription_id": int.tryParse(subscriptionId) ?? subscriptionId,
          "customer_id": int.tryParse(customerId) ?? customerId,
          "pause_dates": formattedDates,
          "pause_type": pauseType,
        },
      );

      // For temporary pause, synchronize legacy WooCommerce metadata if needed
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
                {"key": "pause_date", "value": formattedDates.isNotEmpty ? formattedDates.first : ""},
                {"key": "_pause_date", "value": formattedDates.isNotEmpty ? formattedDates.first : ""},
                {"key": "pause_type", "value": "temporary"},
                {"key": "_pause_type", "value": "temporary"},
                {"key": "is_paused", "value": false},
                {"key": "_is_paused", "value": false},
                {"key": "subscription_is_paused", "value": false},
                {"key": "_subscription_is_paused", "value": false},
              ],
            },
          );
        } catch (_) {}
      }

      if (response.data is Map && response.data['message'] != null) {
        return response.data['message'].toString();
      }

      return 'Subscription paused successfully';
    } catch (e) {
      throw Exception('Failed to Pause Subscription: $e');
    }
  }

  Future<String> resumeSubscription({
    required String subscriptionId,
    required String customerId,
    String? billingPeriod,
    dynamic billingInterval,
    dynamic startDate,
    dynamic currentNextPaymentDate,
  }) async {
    try {
      final subId = int.tryParse(subscriptionId) ?? subscriptionId;
      final custId = int.tryParse(customerId) ?? customerId;

      // 1. Call custom backend Resume endpoint
      dynamic responseData;
      try {
        final response = await dioV2.post(
          ApiConstants.ResumeSubscription,
          data: {
            "subscription_id": subId,
            "customer_id": custId,
          },
        );
        responseData = response.data;
      } catch (_) {}

      // 2. Also ensure backend Pause endpoint clears any stored temporary pause dates
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
      } catch (_) {}

      // 3. Clear WooCommerce subscription pause metadata
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
      } catch (_) {}

      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }

      return 'Subscription resumed successfully';
    } catch (e) {
      throw Exception('Failed to Resume Subscription: $e');
    }
  }
}
