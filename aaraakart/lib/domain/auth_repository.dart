import 'package:aaraa_kart/core/errors/app_exception.dart';
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
      final payload = <String, dynamic>{'phone': mobileNumber};
      final response = await dioV2.post(ApiConstants.SendOTP, data: payload);
      return SendOtpResponse.fromJson(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const RepositoryException('Unable to send OTP. Please try again.');
    }
  }

  Future<bool> deleteProfileCustomer(String customerID) async {
    try {
      final response = await dio.delete(
        '/${ApiConstants.CreateCustomer}/$customerID',
        queryParameters: const {'force': true},
      );
      return response.statusCode == 200;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const RepositoryException('Unable to delete profile. Please try again.');
    }
  }

  Future<VerifyOtpResponse> verifyOTP(String mobileNumber, String otp) async {
    try {
      final payload = <String, dynamic>{'phone': mobileNumber, 'otp': otp};
      final response = await dioV2.post(ApiConstants.VerifyOTP, data: payload);
      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const RepositoryException('Unable to verify OTP. Please try again.');
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
      }
      return CustomerCreateResult.failure(
        'Unable to create customer. Please try again.',
      );
    } on DioException catch (error) {
      return CustomerCreateResult.failure(_mapDioException(error).message);
    } catch (_) {
      return CustomerCreateResult.failure(
        'Unable to create customer. Please try again.',
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
      }
      return CustomerCreateResult.failure('Customer not found.');
    } on DioException catch (error) {
      return CustomerCreateResult.failure(_mapDioException(error).message);
    } catch (_) {
      return CustomerCreateResult.failure(
        'Unable to load customer details. Please try again.',
      );
    }
  }

  Future<GetAddressResponse> createAddress(
    GetAddressResponse addressData,
  ) async {
    try {
      final response = await dioV2.post(
        ApiConstants.Address,
        data: addressData.toJson(),
        queryParameters: {'customer_id': addressData.customerId},
      );
      return GetAddressResponse.fromJson(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const RepositoryException('Unable to create address. Please try again.');
    }
  }

  Future<GetAddressResponse> deleteAddress({
    required String addrID,
    required String userId,
  }) async {
    try {
      final response = await dioV2.delete(
        ApiConstants.Address,
        queryParameters: {
          'customer_id': userId,
          'addr_id': addrID,
        },
      );
      return GetAddressResponse.fromJson(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const RepositoryException('Unable to delete address. Please try again.');
    }
  }

  Future<GetAddressResponse> updateAddress({
    required String addrID,
    required String userId,
  }) async {
    try {
      final response = await dioV2.patch(
        ApiConstants.Address,
        queryParameters: {
          'customer_id': userId,
          'addr_id': addrID,
        },
        data: const {'is_primary': 1},
      );
      return GetAddressResponse.fromJson(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw const RepositoryException('Unable to update address. Please try again.');
    }
  }

  Future<List<GetAddressResponse>> listAddress(String userId) async {
    try {
      final response = await dioV2.get(
        ApiConstants.Address,
        queryParameters: {'customer_id': userId},
      );

      if (response.data is! List) {
        throw const RepositoryException('Unexpected address response from server.');
      }

      return (response.data as List)
          .map((item) => GetAddressResponse.fromJson(item))
          .toList();
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const RepositoryException('Unable to load addresses. Please try again.');
    }
  }

  AppException _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return const UnauthorizedException();
    }
    if (statusCode != null && statusCode >= 500) {
      return const ServerException();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const RepositoryException('Request was cancelled.');
      default:
        return const RepositoryException();
    }
  }
}
