import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastEmailKey = 'last_email';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs?.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    await _prefs?.remove(_tokenKey);
  }

  // User data management
  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await _prefs?.setString(_userKey, userJson);
  }

  Future<UserModel?> getUser() async {
    final userJson = _prefs?.getString(_userKey);
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _prefs?.remove(_userKey);
  }

  // Login state management
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs?.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }

  // Remember me functionality
  Future<void> setRememberMe(bool rememberMe) async {
    await _prefs?.setBool(_rememberMeKey, rememberMe);
  }

  Future<bool> getRememberMe() async {
    return _prefs?.getBool(_rememberMeKey) ?? false;
  }

  Future<void> saveLastEmail(String email) async {
    await _prefs?.setString(_lastEmailKey, email);
  }

  Future<String?> getLastEmail() async {
    return _prefs?.getString(_lastEmailKey);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userKey);
    await _prefs?.setBool(_isLoggedInKey, false);
  }

  // Generic storage methods
  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs?.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs?.getInt(key);
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _prefs?.getDouble(key);
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _prefs?.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<bool> containsKey(String key) async {
    return _prefs?.containsKey(key) ?? false;
  }
}
