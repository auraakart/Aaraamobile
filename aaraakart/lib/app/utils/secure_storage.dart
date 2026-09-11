import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  SecureStorageHelper._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveJsonData(String key, Object? data) async {
    await _storage.write(key: key, value: jsonEncode(data));
  }

  static Future<dynamic> getJsonData(String key) async {
    final value = await _storage.read(key: key);
    if (value == null || value.isEmpty) return null;
    return jsonDecode(value);
  }

  static Future<void> removeData(String key) async {
    await _storage.delete(key: key);
  }
}
