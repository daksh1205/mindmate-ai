import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPrefsService? _instance;
  static SharedPreferences? _preferences;

  // Private constructor
  SharedPrefsService._();

  // Singleton instance getter
  static Future<SharedPrefsService> getInstance() async {
    _instance ??= SharedPrefsService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // User Profile Keys
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatarName = 'user_avatar_name';
  static const String _keyUserAvatarUrl = 'user_avatar_url';
  static const String _keyUserAgeRange = 'user_age_range';
  static const String _keyUserAgeLabel = 'user_age_label';

  // ==================== User Profile Methods ====================

  /// Save user profile data
  Future<bool> saveUserProfile({
    required String name,
    required String avatarName,
    required String avatarUrl,
    required String ageRange,
    required String ageLabel,
  }) async {
    try {
      await _preferences!.setString(_keyUserName, name);
      await _preferences!.setString(_keyUserAvatarName, avatarName);
      await _preferences!.setString(_keyUserAvatarUrl, avatarUrl);
      await _preferences!.setString(_keyUserAgeRange, ageRange);
      await _preferences!.setString(_keyUserAgeLabel, ageLabel);
      return true;
    } catch (e) {
      log('Error saving user profile: $e');
      return false;
    }
  }

  /// Get user name
  String getUserName({String defaultValue = 'User'}) {
    return _preferences!.getString(_keyUserName) ?? defaultValue;
  }

  /// Get user avatar name
  String getUserAvatarName({String defaultValue = 'Kitty'}) {
    return _preferences!.getString(_keyUserAvatarName) ?? defaultValue;
  }

  /// Get user avatar URL
  String getUserAvatarUrl({String defaultValue = ''}) {
    return _preferences!.getString(_keyUserAvatarUrl) ?? defaultValue;
  }

  /// Get user age range
  String getUserAgeRange({String defaultValue = '16-17'}) {
    return _preferences!.getString(_keyUserAgeRange) ?? defaultValue;
  }

  /// Get user age label
  String getUserAgeLabel({String defaultValue = 'MID TEEN'}) {
    return _preferences!.getString(_keyUserAgeLabel) ?? defaultValue;
  }

  /// Check if user profile exists
  bool hasUserProfile() {
    return _preferences!.containsKey(_keyUserName) &&
        _preferences!.containsKey(_keyUserAvatarUrl);
  }

  /// Clear user profile data
  Future<bool> clearUserProfile() async {
    try {
      await _preferences!.remove(_keyUserName);
      await _preferences!.remove(_keyUserAvatarName);
      await _preferences!.remove(_keyUserAvatarUrl);
      await _preferences!.remove(_keyUserAgeRange);
      await _preferences!.remove(_keyUserAgeLabel);
      return true;
    } catch (e) {
      log('Error clearing user profile: $e');
      return false;
    }
  }

  // ==================== General Methods ====================

  /// Save a string value
  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  /// Save a boolean value
  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  /// Save an integer value
  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  /// Save a double value
  Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  /// Get a double value
  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }

  /// Save a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences!.setStringList(key, value);
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    return _preferences!.getStringList(key);
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }

  /// Remove a specific key
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  /// Clear all preferences
  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }
}
