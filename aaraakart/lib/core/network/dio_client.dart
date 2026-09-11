import 'dart:convert';
import 'dart:io';

import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class DioClient {
  static final _logger = Logger();

  // ======================
  // DIO CLIENT BUILDERS
  // ======================

  static Dio _createBasicAuthDio(
      String baseUrl, String username, String password) {
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
    ));

    _addLogging(dio);
    return dio;
  }

  static Dio _createAuthDio(String baseUrl, String username, String password) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      },
    ));

    _addLogging(dio);
    return dio;
  }

  static Dio _createWalletAuthDio(String baseUrl) {
    final api = BrandConfig.instance.api;
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      queryParameters: {
        'consumer_key': api.walletConsumerKey,
        'consumer_secret': api.walletConsumerSecret,
      },
      headers: {'Content-Type': 'application/text'},
    ));

    _addLogging(dio);
    return dio;
  }

  static Dio _createApiKeyDio(String baseUrl, String apiKey) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters.addAll({'key': apiKey});
        return handler.next(options);
      },
    ));

    _addLogging(dio);
    return dio;
  }

  // ======================
  // ERROR MAPPING
  // ======================

  static String _mapDioErrorToMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        if (statusCode == 401 || statusCode == 403) {
          return 'Your session is not authorized for this request.';
        }
        if (statusCode >= 500) {
          return 'The service is temporarily unavailable. Please try again.';
        }
        return 'The request could not be completed. Please check your details and try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No Internet connection. Please check your network.';
        }
        return 'Unexpected network error. Please try again.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }

  // ======================
  // SAFE DEBUG LOGGING
  // ======================

  static void _addLogging(Dio dio) {
    if (!kDebugMode) {
      return;
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d(
          '[HTTP] ${options.method.toUpperCase()} '
          '${options.uri.replace(queryParameters: const {})}',
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d(
          '[HTTP] ${response.statusCode} '
          '${response.requestOptions.method.toUpperCase()} '
          '${response.requestOptions.uri.replace(queryParameters: const {})}',
        );
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        _logger.w(
          '[HTTP] ${error.response?.statusCode ?? 'network-error'} '
          '${error.requestOptions.method.toUpperCase()} '
          '${error.requestOptions.uri.replace(queryParameters: const {})}',
        );

        final friendlyMessage = _mapDioErrorToMessage(error);
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: friendlyMessage,
          ),
        );
      },
    ));
  }

  // ======================
  // API CLIENTS
  // ======================

  static String get _baseUrl => BrandConfig.instance.api.baseUrl;

  static Dio farmersVillageAPI(String username, String password) {
    return _createBasicAuthDio(
      '$_baseUrl/wp-json/wc/v3/',
      username,
      password,
    );
  }

  static Dio farmersVillageAPIv2(String username, String password) {
    return _createAuthDio(
      '$_baseUrl/wp-json',
      username,
      password,
    );
  }

  static Dio googleMapsAPI(String apiKey) {
    return _createApiKeyDio(
      'https://maps.googleapis.com/maps/api/',
      apiKey,
    );
  }

  static Dio walletAPI() {
    return _createWalletAuthDio(
      '$_baseUrl/wp-json/wsfw-route/v1/wallet/',
    );
  }
}
