import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/send_otp_response.dart';
import 'package:aaraa_kart/data/model/user_create_request.dart';
import 'package:aaraa_kart/data/model/user_create_response.dart';
import 'package:aaraa_kart/data/model/verify_otp_response.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio dio;
  final Dio dioV2;

  AuthRepository(this.dio, this.dioV2);
  Future<SendOtpResponse> sendOTP(String mobileNumber) async {
    try {
      Map<String, dynamic> payload = {"phone": mobileNumber};

      final response = await dioV2.post(ApiConstants.SendOTP, data: payload);

      return SendOtpResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to Send OTP: $e');
    }
  }

  Future<bool> deleteProfileCustomer(String customerID) async {
    try {
      final response = await dio.delete(
        '/${ApiConstants.CreateCustomer}/$customerID',
        queryParameters: const {'force': true},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<VerifyOtpResponse> verifyOTP(String mobileNumber, String otp) async {
    try {
      Map<String, dynamic> payload = {"phone": mobileNumber, "otp": otp};

      final response = await dioV2.post(ApiConstants.VerifyOTP, data: payload);

      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.error is String
          ? e.error
          : "Something went wrong. Please try again.";
      throw errorMessage.toString();
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<CustomerCreateResult> createCustomer(UserCreateRequest request) async {
    try {
      final response = await dio.post(
        ApiConstants.CreateCustomer,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return CustomerCreateResult.success(
          UserCreateResponseModel.fromJson(response.data),
        );
      } else {
        return CustomerCreateResult.failure("error");
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data["message"];
      return CustomerCreateResult.failure(
        '${errorData ?? dioError.message}',
      );
    } catch (e) {
      return CustomerCreateResult.failure(
        'Unexpected error: $e',
      );
    }
  }

  Future<CustomerCreateResult> fetchCustomer(String customerID) async {
    try {
      final response = await dio.get(
        '${ApiConstants.CreateCustomer}/$customerID',
      );

      if (response.statusCode == 200 && response.data != null) {
        return CustomerCreateResult.success(
          UserCreateResponseModel.fromJson(response.data),
        );
      } else {
        return CustomerCreateResult.failure("Customer not found");
      }
    } on DioException catch (dioError) {
      final errorData = dioError.response?.data?["message"];
      return CustomerCreateResult.failure(
        errorData ?? dioError.message ?? "Request failed",
      );
    } catch (e) {
      return CustomerCreateResult.failure(
        'Unexpected error: $e',
      );
    }
  }

  Future<GetAddressResponse> createAddress(
      GetAddressResponse addressData) async {
    try {
      final response = await dioV2.post(
        ApiConstants.Address,
        data: addressData.toJson(),
        queryParameters: {'customer_id': addressData.customerId},
      );

      return GetAddressResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Unable to Create Address: $e');
    }
  }

  Future<GetAddressResponse> deleteAddress(
      {required String addrID, required String userId}) async {
    try {
      final response = await dioV2.delete(
        ApiConstants.Address,
        queryParameters: {
          'customer_id': userId,
          'addr_id': addrID,
        },
      );

      return GetAddressResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.error is String
          ? e.error
          : "Something went wrong. Please try again.";
      throw errorMessage.toString();
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<GetAddressResponse> updateAddress(
      {required String addrID, required String userId}) async {
    try {
      final response =
          await dioV2.patch(ApiConstants.Address, queryParameters: {
        'customer_id': userId,
        'addr_id': addrID,
      }, data: {
        'is_primary': 1
      });

      return GetAddressResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.error is String
          ? e.error
          : "Something went wrong. Please try again.";
      throw errorMessage.toString();
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<GetAddressResponse>> listAddress(String userId) async {
    try {
      final response = await dioV2.get(
        ApiConstants.Address,
        queryParameters: {'customer_id': userId},
      );

      return (response.data as List)
          .map((item) => GetAddressResponse.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final errorMessage = e.error is String
          ? e.error
          : "Something went wrong. Please try again.";
      throw errorMessage.toString();
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}


