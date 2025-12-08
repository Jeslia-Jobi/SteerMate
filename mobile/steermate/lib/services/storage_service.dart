import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Token Management
  Future<void> saveToken(String token) async {
    final p = await prefs;
    await p.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final p = await prefs;
    return p.getString(AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    final p = await prefs;
    await p.remove(AppConstants.tokenKey);
  }

  // User Management
  Future<void> saveUser(User user) async {
    final p = await prefs;
    await p.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final p = await prefs;
    final userJson = p.getString(AppConstants.userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> deleteUser() async {
    final p = await prefs;
    await p.remove(AppConstants.userKey);
  }

  // Settings Management
  Future<void> saveSetting(String key, dynamic value) async {
    final p = await prefs;
    if (value is bool) {
      await p.setBool(key, value);
    } else if (value is int) {
      await p.setInt(key, value);
    } else if (value is double) {
      await p.setDouble(key, value);
    } else if (value is String) {
      await p.setString(key, value);
    }
  }

  Future<T?> getSetting<T>(String key) async {
    final p = await prefs;
    return p.get(key) as T?;
  }

  // Clear All Data
  Future<void> clearAll() async {
    final p = await prefs;
    await p.clear();
  }
}
