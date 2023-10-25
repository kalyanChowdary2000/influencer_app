// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreference {}

class PreferenceUtils {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences?> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

  static String getString(String key, [String defValue = ""]) {
    print("get string $key data is ${_prefsInstance?.getString(key)}");
    return _prefsInstance?.getString(key) ?? defValue;
  }

  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }

  static bool getBool(String key, [bool defValue = false]) {
    return _prefsInstance?.getBool(key) ?? defValue;
  }

  static Future<bool> setBool(String key, bool value) async {
    var prefs = await _instance;
    return prefs.setBool(key, value);
  }

  static int getInt(String key, [int defValue = 0]) {
    return _prefsInstance?.getInt(key) ?? defValue;
  }

  static Future<bool> setInt(String key, int value) async {
    var prefs = await _instance;
    return prefs.setInt(key, value);
  }

  static void clearAll() async {
    var prefs = await _instance;
    prefs.clear();
    _prefsInstance?.clear();
  }
}
