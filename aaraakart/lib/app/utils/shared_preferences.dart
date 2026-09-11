import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static Future<void> saveJsonData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(data);
    await prefs.setString(key, jsonString);
  }

  static Future<dynamic> getJsonData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> saveStringList(String key, List<String> myList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, myList);
  }

  static Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }
}


