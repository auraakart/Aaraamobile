import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:logger/logger.dart';

class DioClient {
  static final _logger = Logger();

  // ======================
  // DIO CLIENT BUILDERS
  // ======================

  static Dio _createBasicAuthDio(
      String baseUrl, String username, String password) {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Dio dio = Dio(BaseOptions(
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
    Dio dio = Dio(BaseOptions(
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
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      queryParameters: {
        "consumer_key": api.walletConsumerKey,
        "consumer_secret": api.walletConsumerSecret,
      },
      headers: {'Content-Type': 'application/text'},
    ));

    _addLogging(dio);
    return dio;
  }

  static Dio _createApiKeyDio(String baseUrl, String apiKey) {
    Dio dio = Dio(BaseOptions(
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
        return "Connection timeout. Please check your internet connection.";
      case DioExceptionType.sendTimeout:
        return "Send timeout. Please try again.";
      case DioExceptionType.receiveTimeout:
        return "Server took too long to respond.";
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final serverMessage = error.response?.data?['message'] ??
            error.response?.data?['error'] ??
            'Something went wrong.';
        return "$serverMessage";
      case DioExceptionType.cancel:
        return "Request was cancelled.";
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return "No Internet connection. Please check your network.";
        }
        return "Unexpected error: ${error.message}";
      default:
        return "Something went wrong. Please try again later.";
    }
  }

  // ======================
  // LOGGING INTERCEPTOR
  // ======================

  static void _addLogging(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('[REQUEST]');
        _logger.d('${options.method.toUpperCase()} ${options.uri}');
        if (options.headers.isNotEmpty) {
          _logger.d('Headers: ${options.headers}');
        }
        if (options.data != null) {
          _logger.d('Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i('[RESPONSE]');
        _logger.i(
            '← ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
        _logger.i('Status: ${response.statusCode}');
        _logger.i('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        _logger.e('[ERROR]');
        _logger.e(
            '→ ${e.requestOptions.method.toUpperCase()} ${e.requestOptions.uri}');
        _logger.e('Status Code: ${e.response?.statusCode}');
        _logger.e('Message: ${e.message}');
        if (e.response != null) {
          _logger.e('Response Headers: ${e.response?.headers}');
          _logger.e('Response Data: ${e.response?.data}');
        }
        _logger.e('Request Headers: ${e.requestOptions.headers}');
        if (e.requestOptions.data != null) {
          _logger.e('Request Body: ${e.requestOptions.data}');
        }
        _logger.e('StackTrace: ${e.stackTrace}');

        final friendlyMessage = _mapDioErrorToMessage(e);
        return handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
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


