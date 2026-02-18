

import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
    Future<String?> getUser() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userKey);
    }
  static const String _urlKey = 'uxia_url';
  static const String _tokenKey = 'uxia_token';
  static const String _userKey = 'saved_user';

  Future<void> initialize() async {
  }

  Future<void> saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url);
  }

  Future<String?> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveUser(String user) async {
    final prefs = await SharedPreferences.getInstance();

  }
}